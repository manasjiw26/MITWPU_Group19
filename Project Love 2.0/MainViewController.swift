//
//  MainViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class MainViewController: UITabBarController {
    var loveBot: LoveBotView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let viewControllers = self.viewControllers {
            viewControllers[0].tabBarItem.title = "Vibe"
            viewControllers[0].tabBarItem.image = UIImage(systemName: "heart.circle")
            
            viewControllers[1].tabBarItem.title = "Explore"
            viewControllers[1].tabBarItem.image = UIImage(systemName: "magnifyingglass")
            
            viewControllers[2].tabBarItem.title = "Memory Jar"
            viewControllers[2].tabBarItem.image = UIImage(systemName: "archivebox")
            
            viewControllers[3].tabBarItem.title = "Chat"
            viewControllers[3].tabBarItem.image = UIImage(systemName: "bubble.left")
        }
        setupBot()
    }
    
}

import CoreMotion

extension MainViewController {

    
    func setupBot() {
        // Create an overlay view that covers the whole screen so the bot can fall anywhere
        loveBot = LoveBotView(frame: self.view.bounds)
        loveBot.isUserInteractionEnabled = false // Let touches pass through to your app buttons
        
        // Add it to the very front
        self.view.addSubview(loveBot)
    }

    // MARK: - Detect Shake
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("Shake detected! Dropping bot.")
            
            // Drop him!
            loveBot.dropAndCrash()
            
            // Wait 4 seconds, then climb back up
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                self.loveBot.recoverAndStandUp()
            }
        }
    }
}
