////
////  loginViewController.swift
////  Project Love 2.0
////
////  Created by SDC-USER on 08/12/25.
////
//
//import UIKit
//import GoogleSignIn
//      
//class loginViewController: UIViewController {
//    
//    
//    @IBOutlet weak var emailContainerView: UIView!
//    
//    @IBOutlet weak var passwordContainerView: UIView!
//    
//    @IBOutlet weak var passwordTextField: UITextField!
//    
//    
//    @IBOutlet weak var passwordEyeButton: UIButton!
//
//    @IBOutlet weak var googleContainerView: UIView!
//    
//    
//    @IBOutlet weak var appleContainerView: UIView!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        
//        textboxUi()
//        // Do any additional setup after loading the view.
//        // R
//        // load system images
//        let showImage = UIImage(systemName: "eye")
//        let hideImage = UIImage(systemName: "eye.slash")
//        
//        // assign images for states
//        passwordEyeButton.setImage(hideImage, for: .normal)
//        passwordEyeButton.setImage(showImage, for: .selected)
//        
//        passwordTextField.isSecureTextEntry = true
//        
//       
//        googleContainerView.layer.cornerRadius = 12
//        appleContainerView.layer.cornerRadius = 12
//
//
//        }
//    
//    
//        
//        func textboxUi(){
//            
//            
//            emailContainerView.layer.cornerRadius = emailContainerView.frame.height / 2
//            emailContainerView.layer.masksToBounds = false
//            
//            // White background
//            emailContainerView.backgroundColor = UIColor.white
//            
//            // Shadow
//            emailContainerView.layer.shadowColor = UIColor.black.cgColor
//            emailContainerView.layer.shadowOpacity = 0.08
//            emailContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
//            emailContainerView.layer.shadowRadius = 10
//            
//            
//            // Do any additional setup after loading the view.
//            // Rounded pill shape
//            
//            passwordContainerView.layer.cornerRadius = passwordContainerView.frame.height / 2
//            passwordContainerView.layer.masksToBounds = false
//            
//            // White background
//            passwordContainerView.backgroundColor = UIColor.white
//            
//            // Shadow
//            passwordContainerView.layer.shadowColor = UIColor.black.cgColor
//            passwordContainerView.layer.shadowOpacity = 0.08
//            passwordContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
//            passwordContainerView.layer.shadowRadius = 10
//            
//            
//        }
//        
//        func didTapPasswordEye(_ sender: UIButton) {
//            
//            sender.isSelected.toggle()
//            
//            let wasSecure = passwordTextField.isSecureTextEntry
//            passwordTextField.isSecureTextEntry = !wasSecure
//            
//            // Fix cursor jump
//            let currentText = passwordTextField.text
//            passwordTextField.text = ""
//            passwordTextField.text = currentText
//            
//            
//        }
//    
//    
//    @IBAction func didTapGoogle(_ sender: UIButton) {
//        
//        
//    }
//    
//        
//    @IBAction func didTapApple(_ sender: UIButton) {
//    }
//    
//        
//        /*
//         // MARK: - Navigation
//         
//         // In a storyboard-based application, you will often want to do a little preparation before navigation
//         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//         // Get the new view controller using segue.destination.
//         // Pass the selected object to the new view controller.
//         }
//         */
//        
//    }
//
