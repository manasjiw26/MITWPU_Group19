//
//  signupViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class signupViewController: UIViewController {
    
    
    @IBOutlet weak var EmailContainerView: UIView!
    
    
    @IBOutlet weak var PasswordContainerView: UIView!
    
    @IBOutlet weak var ConfirmPasswordConatinerView: UIView!
    
    
    @IBOutlet weak var EmailTF: UITextField!
    
    
    @IBOutlet weak var PasswordTF: UITextField!
    

    @IBOutlet weak var ConfirmPasswordTF: UITextField!
    
//    @IBOutlet weak var GoogleContainerView: UIView!
//    
    
//    @IBOutlet weak var AppleContainerView: UIView!
//    
//    @IBOutlet weak var PasswordEye: UIButton!
//    
//    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        let showImage = UIImage(systemName: "eye")
//        let hideImage = UIImage(systemName: "eye.slash")
//        
        // assign images for states
//        PasswordEye.setImage(hideImage, for: .normal)
//        PasswordEye.setImage(showImage, for: .selected)
//        
        PasswordTF.isSecureTextEntry = true
        
       
//        GoogleContainerView.layer.cornerRadius = 12
//        AppleContainerView.layer.cornerRadius = 12

    }
    
    func textboxUi(){
        
        
        EmailContainerView.layer.cornerRadius = EmailContainerView.frame.height / 2
        EmailContainerView.layer.masksToBounds = false
        
        // White background
        EmailContainerView.backgroundColor = UIColor.white
        
        // Shadow
        EmailContainerView.layer.shadowColor = UIColor.black.cgColor
        EmailContainerView.layer.shadowOpacity = 0.08
        EmailContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        EmailContainerView.layer.shadowRadius = 10
        
        
        // Do any additional setup after loading the view.
        // Rounded pill shape
        
        PasswordContainerView.layer.cornerRadius = PasswordContainerView.frame.height / 2
        PasswordContainerView.layer.masksToBounds = false
        
        // White background
        PasswordContainerView.backgroundColor = UIColor.white
        
        // Shadow
        PasswordContainerView.layer.shadowColor = UIColor.black.cgColor
        PasswordContainerView.layer.shadowOpacity = 0.08
        PasswordContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        PasswordContainerView.layer.shadowRadius = 10
        
        
    }
    
//    func didTapPasswordEye(_ sender: UIButton) {
//        
//        sender.isSelected.toggle()
//        
//        let wasSecure = PasswordTF.isSecureTextEntry
//        PasswordTF.isSecureTextEntry = !wasSecure
//        
//        // Fix cursor jump
//        let currentText = PasswordTF.text
//        PasswordTF.text = ""
//        PasswordTF.text = currentText
//        
//        
//    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
