//
//  WriteActivityViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 20/01/26.
//

import UIKit

class WriteActivityViewController: UIViewController {

    
    @IBOutlet weak var saveTapped: UIButton!
    @IBOutlet weak var activityTitle: UITextField!
    
  
    @IBOutlet weak var descriptionActivity: UITextView!
    
    @IBOutlet weak var dateText: UITextField!
    
    @IBOutlet weak var calenderImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        saveTapped.configuration = .glass()
        saveTapped.setTitle("Save", for: .normal)
        activityTitle.layer.cornerRadius = 10
        activityTitle.layer.masksToBounds = true
        descriptionActivity.layer.cornerRadius = 10
        descriptionActivity.layer.masksToBounds = true
        dateText.layer.cornerRadius = 10
        dateText.layer.masksToBounds = true
    }

    @IBAction func saveTapped(_ sender: Any) {
        // Capture the text from your descriptionActivity text field
            guard let title = activityTitle.text, !title.isEmpty,
                  let desc = descriptionActivity.text, // This is your 'Description' input
                  let date = dateText.text else { return }
                    
            // 1. Save to DataStore: Ensure 'desc' is passed to the description parameter
            DataStore.shared.addCustomActivity(name: title, description: desc, date: date)
                    
            // 2. Dismiss back to Explore
        self.navigationController?.popViewController(animated: true)
        
    }
}
