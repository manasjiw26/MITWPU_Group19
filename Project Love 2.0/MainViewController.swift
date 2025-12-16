//
//  MainViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class MainViewController: UITabBarController {

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
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
