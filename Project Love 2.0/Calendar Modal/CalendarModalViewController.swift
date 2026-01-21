//
//  CalendarModalViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 14/01/26.
//

import UIKit

protocol ScheduleCalendarDelegate: AnyObject {
    func didSchedule(activity: Activity, on date: Date)
}

class CalendarModalViewController: UIViewController {

    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var tickButton: UIButton!
    @IBOutlet var crossButton: UIButton!
    @IBOutlet var scheduleLabel: UILabel!
    
    var activity: Activity!
    var selectedDate: Date = Date()
    weak var delegate: ScheduleCalendarDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tickButton.configuration = .glass()
        crossButton.configuration = .glass()
        tickButton.setImage(UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), for: .normal )
        
        selectedDate = datePicker.date
        scheduleLabel.isHidden = true

    }
    func confirmSchedule() {
        DataStore.shared.updateScheduledDate(for: activity, date: selectedDate)

        delegate?.didSchedule(activity: activity, on: selectedDate)
        dismiss(animated: true)
    }
    
    private let displayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "d MMM yyyy"
        return df
    }()
    
     func updateScheduledLabel() {
        let dateText = displayFormatter.string(from: selectedDate)
        scheduleLabel.text = "Activity scheduled for \(dateText)"
    }

    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        confirmSchedule()
    }
    @IBAction func selectedDate(_ sender: UIDatePicker) {
        selectedDate = sender.date
        scheduleLabel.isHidden = false
        updateScheduledLabel()
    }
    
}
