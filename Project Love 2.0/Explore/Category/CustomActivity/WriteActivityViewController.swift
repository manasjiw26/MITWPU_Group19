//
//  WriteActivityViewController.swift
//  Project Love 2.0
//

import UIKit

class WriteActivityViewController: UIViewController {

    @IBOutlet weak var saveTapped: UIButton!
    @IBOutlet weak var activityTitle: UITextField!
    @IBOutlet weak var descriptionActivity: UITextView!
    @IBOutlet weak var dateText: UITextField!

    private let datePicker = UIDatePicker()
    private var selectedDate: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        saveTapped.configuration = .glass()
        saveTapped.setTitle("Save", for: .normal)

        styleField(activityTitle)
        styleField(dateText)

        descriptionActivity.layer.cornerRadius = 10
        descriptionActivity.layer.masksToBounds = true

        setupDatePicker()

        // Dismiss date picker / keyboard when tapping anywhere outside
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupDatePicker() {
        datePicker.datePickerMode   = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minimumDate      = Date()
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        dateText.inputView = datePicker
    }

    @objc private func dateChanged() {
        selectedDate = datePicker.date
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
              let desc  = descriptionActivity.text, !desc.isEmpty,
              !dateText.text!.isEmpty else { return }

        // Pass the actual Date object so DataStore can save it as scheduled_date
        DataStore.shared.addCustomActivity(
            name: title,
            description: desc,
            date: dateText.text!,
            scheduledDate: selectedDate
        )

        // Dismiss this view
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
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
