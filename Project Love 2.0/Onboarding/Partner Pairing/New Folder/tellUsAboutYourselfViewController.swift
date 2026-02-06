//
//  tellUsAboutYourselfViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 01/12/25.
//

import UIKit

class tellUsAboutYourselfViewController: UIViewController {
    
    @IBOutlet weak var firstNameTF: UITextField!
    
    
    @IBOutlet weak var birthDateTF: UITextField!
    
    @IBOutlet weak var firstNameContainerView: UIView!
    
    
    @IBOutlet weak var birthDateContainerView: UIView!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var alreadyHaveButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        textboxUi()

        let datePicker = UIDatePicker()
        
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(datePicker:)), for: UIControl.Event.valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.preferredDatePickerStyle = .wheels
        
        birthDateTF.inputView = datePicker
        
        
        // to make keyboard and date pixker disappear
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func dateChanged(datePicker: UIDatePicker ) {
      
        birthDateTF.text = formatDate(datePicker.date)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    
    func textboxUi(){
        
        firstNameContainerView.layer.cornerRadius = 25
        firstNameContainerView.layer.masksToBounds = true
    
    // White background
        firstNameContainerView.backgroundColor = UIColor.white
    

        birthDateContainerView.layer.cornerRadius = birthDateContainerView.frame.height / 2
        birthDateContainerView.layer.masksToBounds = false
    
    // White background
        birthDateContainerView.backgroundColor = UIColor.white
//        getStartedButton.configuration = .glass()
//        getStartedButton.setTitle(NSLocalizedString("Get Started", comment: ""), for: .normal)
//        alreadyHaveButton.configuration = .glass()
//        alreadyHaveButton.setTitle(NSLocalizedString("Already have an account?", comment: ""), for: .normal)
//    
    
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
