//
//  SceneDelegate.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let defaults = UserDefaults.standard
        let onboardingStoryboard = UIStoryboard(name: "Onboarding", bundle: nil)

        if defaults.bool(forKey: "hasCompletedOnboarding") {
            // All onboarding done → go to main app
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            window.rootViewController = mainStoryboard.instantiateInitialViewController()

        } else if defaults.bool(forKey: "hasCompletedPairing") {
            // Pairing done → all done, go to main app
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            window.rootViewController = mainStoryboard.instantiateInitialViewController()
            defaults.set(true, forKey: "hasCompletedOnboarding")

        } else if defaults.bool(forKey: "hasCompletedInfoPages") {
            // Info pages done → go to partner pairing
            let vc = onboardingStoryboard.instantiateViewController(withIdentifier: "PartnerVC") as! partnerViewController
            vc.view.backgroundColor = UIColor(named: "AppBackground")
            window.rootViewController = UINavigationController(rootViewController: vc)

        } else if defaults.bool(forKey: "hasCompletedAssessment") {
            // Assessment done → go to info pages (what the app does)
            let vc = onboardingStoryboard.instantiateViewController(withIdentifier: "infoPageViewController") as! infoPageViewController
            window.rootViewController = UINavigationController(rootViewController: vc)

        } else if defaults.bool(forKey: "hasCompletedBasicInfo") {
            // Basic info done → go to assessment
            let vc = onboardingStoryboard.instantiateViewController(withIdentifier: "assesmentBeginViewController") as! assesmentBeginViewController
            window.rootViewController = UINavigationController(rootViewController: vc)

        } else if defaults.bool(forKey: "hasCompletedAuth") {
            // Auth done → go to basic info
            let vc = onboardingStoryboard.instantiateViewController(withIdentifier: "tellUsAboutYourselfViewController") as! tellUsAboutYourselfViewController
            window.rootViewController = UINavigationController(rootViewController: vc)

        } else {
            // Nothing completed → start from beginning (Onboarding storyboard initial VC)
            window.rootViewController = onboardingStoryboard.instantiateInitialViewController()
        }

        window.makeKeyAndVisible()
        // Listen for partner account deletion globally
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePartnerDeleted),
            name: .partnerAccountDeleted,
            object: nil
        )
    }

    // MARK: - Partner Deletion Alert (fires on any screen)

    @objc private func handlePartnerDeleted() {
        guard let topVC = topViewController() else { return }

        let alert = UIAlertController(
            title: "Partner Left",
            message: "Your partner has deleted their account. Pair with someone new to continue.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Pair", style: .default) { _ in
            let storyboard = UIStoryboard(name: "PartnerPairing", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PartnerPairingViewController")
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            topVC.present(navVC, animated: true)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // Mirror "Skip Pairing" flow
            UserDefaults.standard.set(true, forKey: "didSkipPairing")
            DataStore.shared.currentRelationshipId = nil
            DataStore.shared.partnerUserId = nil
        })

        topVC.present(alert, animated: true)
    }

    /// Walk the VC hierarchy to find the topmost presented controller.
    private func topViewController() -> UIViewController? {
        guard let root = window?.rootViewController else { return nil }
        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }

    // MARK: - Google Sign-In URL handling

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        GIDSignIn.sharedInstance.handle(url)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "hasCompletedOnboarding") {
            ScheduleManager.shared.scheduleAppSideNotifications()
        }
    }


}

