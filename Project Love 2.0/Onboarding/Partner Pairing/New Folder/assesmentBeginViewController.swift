//
//  assesmentBeginViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 05/02/26.
//

import UIKit

class assesmentBeginViewController: UIViewController {

    var userId: UUID?
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    @IBAction func beginButton(_ sender: Any) {
        print("Button tapped")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "questions") as! onboardingQuestionViewController
        self.present(vc, animated: true, completion: nil)
    }
  

}
