//
//  signupOptionsViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 03/02/26.
//

import UIKit
import GoogleSignIn
import Supabase

class signupOptionsViewController: UIViewController {

    @IBOutlet weak var googleLoginButton: UIButton!
    
    let spinner = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.center = view.center
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
    }
   
    // MARK: - Google Sign-In
    
    @IBAction func googleSignIn(_ sender: UIButton) {
        // 1. Read the iOS client ID from Info.plist
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDCLientID") as? String else {
            showAlert("Google Client ID not found in Info.plist")
            return
        }
        
        // 2. Create Google Sign-In configuration
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // 3. Start the Google Sign-In flow
        spinner.startAnimating()
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.showAlert("Google Sign-In failed:\n\(error.localizedDescription)")
                }
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.showAlert("Could not retrieve Google ID token.")
                }
                return
            }
            
            let accessToken = user.accessToken.tokenString
            
            // 4. Sign in to Supabase with the Google ID token
            Task {
                await self.signInWithSupabase(idToken: idToken, accessToken: accessToken)
            }
        }
    }
    
    // MARK: - Supabase Auth with Google Token
    
    private func signInWithSupabase(idToken: String, accessToken: String) async {
        do {
            let session = try await SupabaseManager.shared.client.auth.signInWithIdToken(
                credentials: .init(
                    provider: .google,
                    idToken: idToken,
                    accessToken: accessToken
                )
            )
            
            let userId = session.user.id
            
            // 5. Check if the user already has a profile in the "users" table
            let existingUsers: [DBUser] = try await SupabaseManager.shared.client
                .from("users")
                .select()
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value
            
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                
                UserDefaults.standard.set(true, forKey: "hasCompletedAuth")
                
                if existingUsers.isEmpty {
                    // New user → go to basic-info screen
                    let vc = UIStoryboard(name: "Onboarding", bundle: nil)
                        .instantiateViewController(withIdentifier: "tellUsAboutYourselfViewController") as! tellUsAboutYourselfViewController
                    vc.userId = userId
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    // Returning user → figure out where they left off
                    self.resumeOnboardingFlow(for: existingUsers.first!, userId: userId)
                }
            }
            
        } catch {
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.showAlert("Supabase sign-in failed:\n\(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Resume onboarding for returning Google users
    
    private func resumeOnboardingFlow(for dbUser: DBUser, userId: UUID) {
        let defaults = UserDefaults.standard
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        
        if defaults.bool(forKey: "hasCompletedOnboarding") {
            // Fully onboarded → go to main app
            let mainSB = UIStoryboard(name: "Main", bundle: nil)
            if let mainVC = mainSB.instantiateInitialViewController() {
                self.view.window?.rootViewController = mainVC
                self.view.window?.makeKeyAndVisible()
            }
        } else if defaults.bool(forKey: "hasCompletedPairing") {
            let vc = storyboard.instantiateViewController(withIdentifier: "infoPageViewController") as! infoPageViewController
            navigationController?.pushViewController(vc, animated: true)
        } else if defaults.bool(forKey: "hasCompletedAssessment") {
            let vc = storyboard.instantiateViewController(withIdentifier: "PartnerVC") as! partnerViewController
            navigationController?.pushViewController(vc, animated: true)
        } else if defaults.bool(forKey: "hasCompletedBasicInfo") {
            let vc = storyboard.instantiateViewController(withIdentifier: "assesmentBeginViewController") as! assesmentBeginViewController
            navigationController?.pushViewController(vc, animated: true)
        } else {
            // Profile exists but basic info not completed locally → go to basic info
            defaults.set(true, forKey: "hasCompletedAuth")
            let vc = storyboard.instantiateViewController(withIdentifier: "tellUsAboutYourselfViewController") as! tellUsAboutYourselfViewController
            vc.userId = userId
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Email Sign Up
    
    @IBAction func signupEmailTapped(_ sender: Any) {
        let vc = UIStoryboard(
                name: "Onboarding",   
                bundle: nil
            ).instantiateViewController(
                withIdentifier: "CreateAccountViewController"
            ) as! CreateAccountViewController
            
            navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Helpers
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
