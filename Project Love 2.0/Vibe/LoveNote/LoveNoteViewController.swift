//
//  LoveNoteViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 17/12/25.
//

import UIKit

class LoveNoteViewController: UIViewController {
        @IBOutlet weak var textField: UITextField!
        @IBOutlet weak var overlayView: UIView!
        @IBOutlet weak var containerView: UIView!
        @IBOutlet weak var scheduleButton: UIButton!

        @IBOutlet weak var datePicker: UIDatePicker!

    
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            datePicker.isHidden = true
        }


        private func setupUI() {
            overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.25)

            containerView.layer.cornerRadius = 20
            containerView.clipsToBounds = true
        }

        

        

        

        @IBAction func scheduleTapped(_ sender: UIButton) {
            datePicker.isHidden.toggle()
        }

        @IBAction func datePickerChanged(_ sender: UIDatePicker) {
            let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"   // TIME ONLY

                let time = formatter.string(from: sender.date)
                scheduleButton.setTitle(" Scheduled for \(time)", for: .normal)
            datePicker.isHidden = true
        }

        
        @IBAction func closeTapped(_ sender: UIButton) {
            dismiss(animated: true)
        }
        
        @IBAction func saveTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

        

        
    }
