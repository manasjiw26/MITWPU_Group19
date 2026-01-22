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
    
    private let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveTapped.configuration = .glass()
        saveTapped.setTitle("Save", for: .normal)
        
        activityTitle.layer.cornerRadius = 10
        activityTitle.layer.masksToBounds = true
        
        descriptionActivity.layer.cornerRadius = 10
        descriptionActivity.layer.masksToBounds = true
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        dateText.layer.cornerRadius = 10
        dateText.layer.masksToBounds = true
        dateText.inputView = datePicker
        updateDateText(date: Date())
        
        
        
    }
    private func updateDateText(date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateText.text = formatter.string(from: date)
    }

    @IBAction func saveTapped(_ sender: Any) {

            guard let title = activityTitle.text, !title.isEmpty,
                  let desc = descriptionActivity.text, // This is your 'Description' input
                  let date = dateText.text else { return }
                    
            // 1. Save to DataStore: Ensure 'desc' is passed to the description parameter
            DataStore.shared.addCustomActivity(name: title, description: desc, date: date)
                    
            // 2. Dismiss back to Explore
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc private func datePickerValueChanged() {
        updateDateText(date: datePicker.date)
    }
    
    
}
