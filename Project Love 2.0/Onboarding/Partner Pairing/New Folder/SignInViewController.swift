//
//  SignInViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 04/02/26.
//

import UIKit
import Supabase

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var TFView: [UIView]!
    @IBOutlet var imageView: [UIImageView]!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    let spinner = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.center = view.center
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        
        viewDidLayoutSubviews()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        emailTF.delegate = self
        passwordTF.delegate = self

        emailTF.returnKeyType = .next
        passwordTF.returnKeyType = .done
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func getStartedTapped(_ sender: Any) {
        guard let email = emailTF.text, !email.isEmpty,
                  let password = passwordTF.text, !password.isEmpty else {
                showAlert("Email and password are required")
                return
            }
        spinner.startAnimating()

            Task { await login(email: email, password: password) }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTF {
            passwordTF.becomeFirstResponder()   // Move to password
        } else if textField == passwordTF {
            textField.resignFirstResponder()    // Dismiss keyboard
            
            // Optional: auto login when Done pressed
            getStartedTapped(UIButton())
        }
        return true
    }
    // Lightweight struct to decode user row
    private struct UserRow: Codable {
        let user_id: UUID
        let relationship_id: UUID?
        let gender: String?
        let assessment_answers: [String: [Int]]?
    }


    func login(email: String, password: String) async {
        do {
            let response = try await SupabaseManager.shared.client.auth.signIn(
                email: email,
                password: password
            )

            let user = response.user

            // Query users table to check if already paired
            let rows: [UserRow] = try await SupabaseManager.shared.client
                .from("users")
                .select("user_id, relationship_id, gender, assessment_answers")
                .eq("user_id", value: user.id.uuidString)
                .execute()
                .value

            let userRow = rows.first
            let hasAssessment = !(userRow?.assessment_answers?.isEmpty ?? true)
            if let gender = userRow?.gender, !gender.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                UserDefaults.standard.set(gender, forKey: "userGender")
            }
            await DataStore.shared.refreshUserProfileFromSupabase()

            DispatchQueue.main.async {
                self.spinner.stopAnimating()

                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "hasCompletedAuth")
                defaults.set(true, forKey: "hasCompletedBasicInfo")

                let onboardingSB = UIStoryboard(name: "Onboarding", bundle: nil)

                if let row = userRow, row.relationship_id != nil {
                    // Already paired → mark all stages done and go to main app
                    defaults.set(true, forKey: "hasCompletedAssessment")
                    defaults.set(true, forKey: "hasCompletedPairing")
                    defaults.set(true, forKey: "hasCompletedOnboarding")

                    let mainSB = UIStoryboard(name: "Main", bundle: nil)
                    guard let mainVC = mainSB.instantiateInitialViewController() else { return }
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let sceneDelegate = windowScene.delegate as? SceneDelegate,
                       let window = sceneDelegate.window {
                        window.rootViewController = mainVC
                        window.makeKeyAndVisible()
                    }
                } else {
                    // Not paired yet → go to assessment (then partner pairing)
                    let vc = onboardingSB.instantiateViewController(withIdentifier: "assesmentBeginViewController") as! assesmentBeginViewController
                    vc.userId = user.id
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }

        } catch {
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                let message = error.localizedDescription.lowercased()

                if message.contains("invalid login credentials") ||
                   message.contains("invalid") ||
                   message.contains("password") {
                    self.showAlert("Incorrect email or password")
                } else {
                    self.showAlert("Login failed.\n\(error.localizedDescription)")
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyCornerStyles()
    }
    
    private func applyCornerStyles() {
        TFView.forEach {
            $0.layer.cornerRadius = $0.frame.height / 2
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray6.cgColor
        }
    
    }
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
 }
