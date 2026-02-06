//
//  CreateAccountViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 04/02/26.
//

import UIKit

class CreateAccountViewController: UIViewController {
    @IBOutlet var TFView: [UIView]!
    @IBOutlet var imageView: [UIImageView]!
    @IBOutlet weak var signUpButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
        print("hello")
        viewDidLayoutSubviews()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyCornerStyles()
    }
    func setup(){
        
    }
    private func applyCornerStyles() {
        TFView.forEach {
            $0.layer.cornerRadius = $0.frame.height / 2
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray6.cgColor
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
