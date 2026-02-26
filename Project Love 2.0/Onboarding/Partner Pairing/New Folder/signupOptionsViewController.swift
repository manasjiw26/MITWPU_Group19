//
//  signupOptionsViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 03/02/26.
//

import UIKit

class signupOptionsViewController: UIViewController {

    @IBOutlet weak var appleLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
   
    @IBAction func signupEmailTapped(_ sender: Any) {
        let vc = UIStoryboard(
                name: "Onboarding",   
                bundle: nil
            ).instantiateViewController(
                withIdentifier: "CreateAccountViewController"
            ) as! CreateAccountViewController
            
            navigationController?.pushViewController(vc, animated: true)
    }
}
