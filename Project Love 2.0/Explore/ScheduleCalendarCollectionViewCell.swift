//
//  ScheduleCalendarCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 12/01/26.
//

import UIKit

class ScheduleCalendarCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!

    var onDateChanged: ((Date) -> Void)?

       override func awakeFromNib() {
           super.awakeFromNib()
           contentView.backgroundColor = .white
           contentView.layer.cornerRadius = 20
           
           datePicker.preferredDatePickerStyle = .inline
           datePicker.translatesAutoresizingMaskIntoConstraints = false
       }
    

       @IBAction func dateChanged(_ sender: UIDatePicker) {
           onDateChanged?(sender.date)
       }

    func configure(with date: Date) {
        if datePicker.date != date {
            datePicker.date = date
        }
    }

}
