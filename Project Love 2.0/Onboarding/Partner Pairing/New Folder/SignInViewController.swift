//
//  SignInViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 04/02/26.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet var TFView: [UIView]!
    @IBOutlet var imageView: [UIImageView]!
    @IBOutlet weak var getStarted: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLayoutSubviews()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyCornerStyles()
    }
    private func applyCornerStyles() {
        TFView.forEach {
            $0.layer.cornerRadius = $0.frame.height / 2
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray6.cgColor
        }
    
    }
 }
