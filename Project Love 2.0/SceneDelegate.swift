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
            // Pairing done → go to app brief (infoPageVC)
            let vc = onboardingStoryboard.instantiateViewController(withIdentifier: "infoPageViewController") as! infoPageViewController
            window.rootViewController = UINavigationController(rootViewController: vc)

        } else if defaults.bool(forKey: "hasCompletedAssessment") {
            // Assessment done → go to partner pairing
            let vc = onboardingStoryboard.instantiateViewController(withIdentifier: "PartnerVC") as! partnerViewController
            vc.view.backgroundColor = UIColor(named: "AppBackground")
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
    }


}

