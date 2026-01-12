//
//  newAddNewViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 12/01/26.
//

import UIKit

class newAddNewViewController: UIViewController {
    
    @IBOutlet var textFieldView: [UIView]!
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var memoryTitleTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    func setupUI() {
        for i in 0..<textFieldView.count {
            textFieldView[i].layer.cornerRadius = 10
            textFieldView[i].clipsToBounds = true
        }
        dateTextField.layer.cornerRadius = 10
        dateTextField.clipsToBounds = true
        locationTextField.layer.cornerRadius = 10
        descriptionTextField.layer.cornerRadius = 10
        memoryTitleTextField.layer.cornerRadius = 10
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
