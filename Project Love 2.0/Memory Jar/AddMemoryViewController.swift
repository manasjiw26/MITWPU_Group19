//
//  AddMemoryViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 17/12/25.
//

import UIKit

class AddMemoryViewController: UIViewController {

    
    @IBOutlet weak var AddMemoryCloseButton: UIButton!
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet weak var AddMemoryDoneButton: UIButton!
    
    @IBOutlet weak var titleButton: UIButton!
    
    @IBOutlet weak var addPhotoView: UIView!
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var calendarIconView: UIView!
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var locationIconView: UIView!
    
    @IBOutlet weak var descriptionTextView: UITextField!
    
    var selectedImage: UIImage?
    var selectedImageName: String?
    var selectedTitle: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        AddMemoryCloseButton.configuration = .glass()
        AddMemoryCloseButton.setImage(UIImage(
            systemName: "xmark",
            withConfiguration: UIImage.SymbolConfiguration(weight: .medium)),
        for: .normal)
        
        AddMemoryDoneButton.configuration = .glass()
        AddMemoryDoneButton.setImage(UIImage(
            systemName: "checkmark",
            withConfiguration: UIImage.SymbolConfiguration(weight: .medium)),
        for: .normal)
        // Do any additional setup after loading the view.
        dateTextField.rightView = calendarIconView
          dateTextField.rightViewMode = .always
        
        locationTextField.rightView = locationIconView
          locationTextField.rightViewMode = .always
        
        setupTitleButton()
        setupPhotoView()
        styleTextField()
        
        
    }
    
    private func setupTitleButton() {
           titleButton.layer.cornerRadius = 14
           titleButton.backgroundColor = .white
           titleButton.setTitle("Choose Memory Title", for: .normal)
           titleButton.setTitleColor(.secondaryLabel, for: .normal)
           titleButton.contentHorizontalAlignment = .left
           
       }
    private func setupPhotoView() {
           addPhotoView.layer.cornerRadius = 16
          
        addPhotoView.backgroundColor = .white
               
         
       }
    
    private func styleTextField() {
          dateTextField.layer.cornerRadius = 14
          dateTextField.borderStyle = .none
        dateTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        dateTextField.leftViewMode = .always
        
        locationTextField.layer.cornerRadius = 14
        locationTextField.borderStyle = .none
        locationTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        locationTextField.leftViewMode = .always
        
        
        descriptionTextView.layer.cornerRadius = 14
        descriptionTextView.borderStyle = .none
        descriptionTextView.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        descriptionTextView.leftViewMode = .always
        
      }
    
    
    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    
    @IBAction func doneTapped(_ sender: UIButton) {
        
        let alert = UIAlertController(
                  title: "Memory Added!",
                  message: "Your memory has been saved successfully.",
                  preferredStyle: .alert
              )
              alert.addAction(UIAlertAction(title: "OK", style: .default))
              present(alert, animated: true)
        
    }
    
}
