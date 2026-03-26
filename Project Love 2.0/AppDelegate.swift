//
//  AppDelegate.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit
import GoogleSignIn
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {



    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Request Push Notification Authorization
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    // application.registerForRemoteNotifications() // Uncomment if you setup Apple Developer account correctly for remote pushes
                }
            }
        }

        return true
    }

    // MARK: - Google Sign-In URL handling

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }



    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let notificationType = userInfo["notificationType"] as? String {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first?.rootViewController else {
                completionHandler()
                return
            }
            
            // Adapt this routing to your app's actual TabBarController architecture if needed.
            if let tabBarController = rootVC as? UITabBarController {
                tabBarController.selectedIndex = 0 // assuming Home is tab 0
                
                guard let navController = tabBarController.viewControllers?.first as? UINavigationController else {
                    completionHandler()
                    return
                }
                
                if notificationType == "lovenote" {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil) // Update Storyboard if needed
                    if let vc = storyboard.instantiateViewController(withIdentifier: "LoveNoteViewController") as? UIViewController {
                        navController.pushViewController(vc, animated: true)
                    }
                } else if notificationType == "mood" {
                    let storyboard = UIStoryboard(name: "Mood", bundle: nil) 
                    if let vc = storyboard.instantiateViewController(withIdentifier: "MoodViewController") as? UIViewController {
                        navController.pushViewController(vc, animated: true)
                    }
                } else if notificationType == "motivational" {
                    navController.popToRootViewController(animated: true)
                }
            } else if let navController = rootVC as? UINavigationController {
                if notificationType == "motivational" {
                    navController.popToRootViewController(animated: true)
                }
            }
        }
        
        completionHandler()
    }

}

