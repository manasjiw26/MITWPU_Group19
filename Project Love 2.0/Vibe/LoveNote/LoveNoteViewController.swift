//
//  LoveNoteViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 17/12/25.
//

import UIKit

class LoveNoteViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scheduleButton: UIButton!

    private var scheduledDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        containerView.layer.cornerRadius = 20
        containerView.clipsToBounds = true
    }


    @IBAction func scheduleTapped(_ sender: UIButton) {
        view.endEditing(true)
        presentSchedulePopover(from: sender)
    }

    private func presentSchedulePopover(from button: UIButton) {
        let popoverVC = UIViewController()
        popoverVC.modalPresentationStyle = .popover
        popoverVC.preferredContentSize = CGSize(width: 240, height: 70)
        popoverVC.view.backgroundColor = .systemBackground

        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        datePicker.addTarget(
            self,
            action: #selector(dateChanged(_:)),
            for: .valueChanged
        )

        popoverVC.view.addSubview(datePicker)

        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: popoverVC.view.centerXAnchor),
            datePicker.topAnchor.constraint(equalTo: popoverVC.view.topAnchor, constant: 28)
        ])

        if let popover = popoverVC.popoverPresentationController {
            popover.sourceView = button
            popover.sourceRect = CGRect(x: button.bounds.midX, y: button.bounds.maxY, width: 0, height: 0)
            popover.permittedArrowDirections = .up
            popover.delegate = self
        }

        present(popoverVC, animated: true)
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        scheduledDate = sender.date

        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, h:mm a"
        let time = formatter.string(from: sender.date)

        scheduleButton.setTitle(" Scheduled for \(time)", for: .normal)
    }

    

    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        // scheduledDate is available here if needed
        dismiss(animated: true)
    }
}



extension LoveNoteViewController {
    func adaptivePresentationStyle(
        for controller: UIPresentationController
    ) -> UIModalPresentationStyle {
        return .none   // Forces popover instead of fullscreen
    }
}
