//
//  assesmentBeginViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 05/02/26.
//

import UIKit
import Supabase

class assesmentBeginViewController: UIViewController {

    var userId: UUID?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Fallback: if userId wasn't passed (e.g. resumed from SceneDelegate), get from Supabase session
        if userId == nil {
            userId = SupabaseManager.shared.client.auth.currentUser?.id
        }
    }
    

    @IBAction func beginButton(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "questions") as! onboardingQuestionViewController
        self.present(vc, animated: true, completion: nil)
    }
  

}
