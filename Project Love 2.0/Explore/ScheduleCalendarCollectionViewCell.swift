import UIKit

@available(iOS 16.0, *)
class ScheduleCalendarCollectionViewCell: UICollectionViewCell {

    private var calendarView: UICalendarView!
    private var activityDates: [Date] = []

    var onDateChanged: ((Date) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCalendar()
    }

    private func setupCalendar() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = true

        let calendar = UICalendarView()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.calendar = .current
        calendar.locale = .current
        calendar.fontDesign = .rounded
        calendar.delegate = self
        calendar.tintColor = UIColor(named: "PurpleColor")!
        calendar.preservesSuperviewLayoutMargins = false
        calendar.directionalLayoutMargins = .zero
        calendar.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)


        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendar.selectionBehavior = selection

        contentView.addSubview(calendar)

        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            calendar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            calendar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            calendar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])

        //calendar.heightAnchor.constraint(equalToConstant: 420).isActive = true

        self.calendarView = calendar
    }

    func configure(selectedDate: Date, activityDates: [Date]) {
        self.activityDates = activityDates

        let components = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)

        if let selection = calendarView.selectionBehavior as? UICalendarSelectionSingleDate {
            selection.setSelected(components, animated: false)
        }

        let datesToReload = activityDates.map {
            Calendar.current.dateComponents([.year, .month, .day], from: $0)
        }

        calendarView.reloadDecorations(forDateComponents: datesToReload, animated: true)
    }
}
@available(iOS 16.0, *)
extension ScheduleCalendarCollectionViewCell: UICalendarViewDelegate {

    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents ) -> UICalendarView.Decoration? {

        let hasActivity = activityDates.contains {
            Calendar.current.isDate(
                $0,
                equalTo: Calendar.current.date(from: dateComponents)!,
                toGranularity: .day
            )
        }

        return hasActivity
            ? .default(color: UIColor(named: "PurpleColor")!, size: .small)
            : nil
    }
}
@available(iOS 16.0, *)
extension ScheduleCalendarCollectionViewCell: UICalendarSelectionSingleDateDelegate {

    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents? ) {
        guard let date = Calendar.current.date(from: dateComponents!) else { return }
        onDateChanged?(date)
    }
}
