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
    
    private let forgotPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Forgot Password?", for: .normal)
        btn.contentHorizontalAlignment = .right
        btn.setTitleColor(.systemIndigo, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
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
        
        setupForgotPasswordButton()
    }
    
    private func setupForgotPasswordButton() {
        view.addSubview(forgotPasswordButton)
        
        // TFView array typically has the password container view at index 1
        if TFView.count >= 2 {
            let passwordView = TFView[1]
            NSLayoutConstraint.activate([
                forgotPasswordButton.topAnchor.constraint(equalTo: passwordView.bottomAnchor, constant: 8),
                forgotPasswordButton.trailingAnchor.constraint(equalTo: passwordView.trailingAnchor),
                forgotPasswordButton.heightAnchor.constraint(equalToConstant: 30)
            ])
        } else {
            NSLayoutConstraint.activate([
                forgotPasswordButton.topAnchor.constraint(equalTo: passwordTF.bottomAnchor, constant: 16),
                forgotPasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                forgotPasswordButton.heightAnchor.constraint(equalToConstant: 30)
            ])
        }
        
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
    }

    @objc private func forgotPasswordTapped() {
        let alert = UIAlertController(title: "Reset Password", message: "Enter your email address to receive a password reset link.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Email Address"
            textField.keyboardType = .emailAddress
            textField.text = self.emailTF.text // pre-fill
        }
        
        let sendAction = UIAlertAction(title: "Send Link", style: .default) { _ in
            guard let email = alert.textFields?.first?.text, !email.isEmpty else { return }
            self.sendPasswordReset(email: email)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(sendAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }

    private func sendPasswordReset(email: String) {
        spinner.startAnimating()
        Task {
            do {
                try await SupabaseManager.shared.client.auth.resetPasswordForEmail(email)
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.showOTPInputAlert(for: email)
                }
            } catch {
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.showAlert("Failed to send reset link: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showOTPInputAlert(for email: String) {
        let alert = UIAlertController(title: "Enter Reset Code", message: "Check your email for the 6-digit code.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "6-digit OTP Code"
            textField.keyboardType = .numberPad
        }
        alert.addTextField { textField in
            textField.placeholder = "New Password"
            textField.isSecureTextEntry = true
        }
        
        let verifyAction = UIAlertAction(title: "Update Password", style: .default) { _ in
            guard let otp = alert.textFields?[0].text, !otp.isEmpty,
                  let newPassword = alert.textFields?[1].text, !newPassword.isEmpty else {
                self.showAlert("OTP and New Password cannot be empty.")
                return
            }
            self.verifyOTPAndResetPassword(email: email, otp: otp, newPassword: newPassword)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(verifyAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }

    private func verifyOTPAndResetPassword(email: String, otp: String, newPassword: String) {
        spinner.startAnimating()
        Task {
            do {
                // 1. Verify OTP
                try await SupabaseManager.shared.client.auth.verifyOTP(
                    email: email,
                    token: otp,
                    type: .recovery
                )
                
                // 2. Update Password for the now-authenticated user
                try await SupabaseManager.shared.client.auth.update(user: UserAttributes(password: newPassword))
                
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.showAlert("Your password has been updated successfully! You can now log in.", title: "Success")
                }
            } catch {
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.showAlert("Failed to update password: \(error.localizedDescription)")
                }
            }
        }
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
            _ = !(userRow?.assessment_answers?.isEmpty ?? true)
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
    func showAlert(_ message: String, title: String = "Error") {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
 }
