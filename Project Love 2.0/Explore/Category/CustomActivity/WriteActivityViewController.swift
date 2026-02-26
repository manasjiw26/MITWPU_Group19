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

    private let datePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()

        saveTapped.configuration = .glass()
        saveTapped.setTitle("Save", for: .normal)

        styleField(activityTitle)
        styleField(dateText)

        descriptionActivity.layer.cornerRadius = 10
        descriptionActivity.layer.masksToBounds = true
        
        setupDatePicker()

    }
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minimumDate = Date()
        
        datePicker.addTarget(self,
                             action: #selector(dateChanged),
                             for: .valueChanged)
        
        dateText.inputView = datePicker
    }
    
    @objc private func dateChanged() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateText.text = formatter.string(from: datePicker.date)
    }
    private func styleField(_ textField: UITextField) {
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
        textField.setLeftPaddingPoints(8)
    }

    @IBAction func saveTapped(_ sender: Any) {
        guard let title = activityTitle.text, !title.isEmpty,
              let desc = descriptionActivity.text, !desc.isEmpty,
              let date = dateText.text, !date.isEmpty else { return }

        DataStore.shared.addCustomActivity(name: title, description: desc, date: date)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func calendarTapped(_ sender: Any) {
        dateText.becomeFirstResponder()
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.height))
        leftView = paddingView
        leftViewMode = .always
    }
}

