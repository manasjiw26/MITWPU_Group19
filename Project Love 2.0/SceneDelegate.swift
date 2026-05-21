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

    /// Holds the next screen while it warms up behind the splash
    private var preloadedVC: UIViewController?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // Show splash screen immediately
        let splashVC = SplashViewController()
        window.rootViewController = splashVC
        window.makeKeyAndVisible()

        // Preload the real destination in the background while splash plays.
        // This triggers viewDidLoad + all Supabase fetches so the screen is
        // fully ready by the time the splash animation ends.
        DispatchQueue.main.async {
            self.preloadedVC = self.buildNextViewController()
            // Force the view to load now (triggers viewDidLoad + data fetching)
            _ = self.preloadedVC?.view
        }

        // Listen for partner account deletion globally
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePartnerDeleted),
            name: .partnerAccountDeleted,
            object: nil
        )
    }

    /// Builds the correct next view controller based on onboarding state.
    private func buildNextViewController() -> UIViewController {
        let defaults = UserDefaults.standard
        let onboardingStoryboard = UIStoryboard(name: "Onboarding", bundle: nil)

        if defaults.bool(forKey: "hasCompletedOnboarding") {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            return mainStoryboard.instantiateInitialViewController()!

        } else if defaults.bool(forKey: "hasCompletedPairing") {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            defaults.set(true, forKey: "hasCompletedOnboarding")
            return mainStoryboard.instantiateInitialViewController()!

        } else if defaults.bool(forKey: "hasCompletedInfoPages") {
            let vc = onboardingStoryboard.instantiateViewController(withIdentifier: "PartnerVC") as! partnerViewController
            vc.view.backgroundColor = UIColor(named: "AppBackground")
            return UINavigationController(rootViewController: vc)

        } else if defaults.bool(forKey: "hasCompletedAssessment") {
            let vc = onboardingStoryboard.instantiateViewController(withIdentifier: "infoPageViewController") as! infoPageViewController
            return UINavigationController(rootViewController: vc)

        } else if defaults.bool(forKey: "hasCompletedBasicInfo") {
            let vc = onboardingStoryboard.instantiateViewController(withIdentifier: "assesmentBeginViewController") as! assesmentBeginViewController
            return UINavigationController(rootViewController: vc)

        } else if defaults.bool(forKey: "hasCompletedAuth") {
            let vc = onboardingStoryboard.instantiateViewController(withIdentifier: "tellUsAboutYourselfViewController") as! tellUsAboutYourselfViewController
            return UINavigationController(rootViewController: vc)

        } else {
            return onboardingStoryboard.instantiateInitialViewController()!
        }
    }

    /// Called by SplashViewController after its animation completes.
    /// The destination screen is already loaded — just swap it in instantly.
    func showMainApp() {
        guard let window = self.window else { return }

        // Use preloaded VC if ready, otherwise build it now (fallback)
        let nextVC = preloadedVC ?? buildNextViewController()
        preloadedVC = nil  // release reference

        // Instant swap — native iOS splash behaviour, no animation
        window.rootViewController = nextVC
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

        // Handle widget deep-link: memorylane://open?id=<memoryId>
        if url.scheme == "memorylane" {
            navigateToMemoryJar()
            return
        }

        // Handle Google Sign-In callback
        GIDSignIn.sharedInstance.handle(url)
    }

    /// Switches to the Memory Jar tab when the widget is tapped.
    private func navigateToMemoryJar() {
        guard let tabBarController = window?.rootViewController as? UITabBarController else { return }
        // Memory Jar is typically the 3rd tab (index 2) — adjust if needed
        tabBarController.selectedIndex = 2
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

