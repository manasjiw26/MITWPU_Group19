import UIKit

protocol LNScheduleCellDelegate: AnyObject {
    func didUpdateDate(for note: LoveNote, to newDate: Date)
}

class LNScheduleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timepicker: UIDatePicker!
    
    @IBOutlet weak var dateEditButton: UIButton!
    @IBOutlet weak var timeEditButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet var view: [UIView]!
    
    private var currentNote: LoveNote?
    weak var delegate: LNScheduleCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        view.forEach { $0.layer.cornerRadius = 10 }
        
        // Keep pickers "hidden" but interactive
        datePicker.alpha = 0.01
        timepicker.alpha = 0.01
        
        // Setup value change listeners
        datePicker.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
        timepicker.addTarget(self, action: #selector(timePickerChanged(_:)), for: .valueChanged)
        
        // Link the edit buttons to trigger the invisible pickers
        dateEditButton.addTarget(self, action: #selector(triggerDatePicker), for: .touchUpInside)
        timeEditButton.addTarget(self, action: #selector(triggerTimePicker), for: .touchUpInside)
    }

    // MARK: - Button Actions
    @objc private func triggerDatePicker() {
        // This programmatically "taps" the picker to open the calendar
        datePicker.sendActions(for: .touchUpInside)
    }

    @objc private func triggerTimePicker() {
        // This programmatically "taps" the picker to open the time wheel
        timepicker.sendActions(for: .touchUpInside)
    }

    func configureCells(with note: LoveNote, isEditing: Bool) {
        self.currentNote = note
        
        dateEditButton.isHidden = !isEditing
        timeEditButton.isHidden = !isEditing
        
        // Ensure the pickers can be interacted with
        datePicker.isUserInteractionEnabled = isEditing
        timepicker.isUserInteractionEnabled = isEditing
        
        if let scheduledDate = note.scheduledDate {
            datePicker.date = scheduledDate
            timepicker.date = scheduledDate
            updateLabels(with: scheduledDate)
        }
    }

    @objc private func datePickerChanged(_ sender: UIDatePicker) {
        combineAndApply(newDate: sender.date, fromDateMode: true)
    }

    @objc private func timePickerChanged(_ sender: UIDatePicker) {
        combineAndApply(newDate: sender.date, fromDateMode: false)
    }

    private func combineAndApply(newDate: Date, fromDateMode: Bool) {
        let existingDate = currentNote?.scheduledDate ?? Date()
        
        var calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: existingDate)
        
        if fromDateMode {
            let d = calendar.dateComponents([.year, .month, .day], from: newDate)
            components.year = d.year
            components.month = d.month
            components.day = d.day
        } else {
            let t = calendar.dateComponents([.hour, .minute], from: newDate)
            components.hour = t.hour
            components.minute = t.minute
        }
        
        if let updatedFullDate = calendar.date(from: components) {
            applyUpdate(newDate: updatedFullDate)
        }
    }

    private func applyUpdate(newDate: Date) {
        updateLabels(with: newDate)
        self.currentNote?.scheduledDate = newDate
        
        // Keep both pickers in sync
        datePicker.date = newDate
        timepicker.date = newDate
        
        delegate?.didUpdateDate(for: currentNote!, to: newDate)
    }

    private func updateLabels(with date: Date) {
        dateLabel.text = date.formatted(date: .abbreviated, time: .omitted)
        timeLabel.text = date.formatted(date: .omitted, time: .shortened)
    }
}
