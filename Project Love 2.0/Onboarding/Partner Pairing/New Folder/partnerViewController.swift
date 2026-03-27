//
//  partnerViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class partnerViewController: UIViewController {
    
    
    @IBOutlet weak var inviteButton: UIButton!
    
    
    @IBOutlet weak var enterCodeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    
    @IBAction func skipTapped(_ sender: Any) {
        
        UserDefaults.standard.set(true, forKey: "hasCompletedPairing")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        view.isUserInteractionEnabled = true
            
        UserDefaults.standard.set(true, forKey: "didSkipPairing")
            
        let mainSB = UIStoryboard(name: "Main", bundle: nil)
        guard let mainVC = mainSB.instantiateInitialViewController() else { return }
            
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.rootViewController = mainVC
            window.makeKeyAndVisible()
        }
    }
}
