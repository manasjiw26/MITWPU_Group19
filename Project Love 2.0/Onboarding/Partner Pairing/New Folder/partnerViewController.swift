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
    
  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
