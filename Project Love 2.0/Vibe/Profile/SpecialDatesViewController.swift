import UIKit

class SpecialDatesViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var addSpecial: UIView!
    @IBOutlet weak var containerCell: UIView!
    @IBOutlet weak var saveTapped: UIButton!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!

    let notePlaceholder = "Note"
    var selectedDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Special Dates"
        view.backgroundColor = .systemGroupedBackground

        saveTapped.configuration = .glass()
        saveTapped.setTitle("Save", for: .normal)

        dateField.delegate = self
        noteTextView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self

        setupNotePlaceholder()
        addSeparators()
        setupCollectionLayout()

        let nib = UINib(nibName: "SpecialDateCollectionCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "SpecialDateCollectionCell")

        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {

        guard let title = titleField.text, !title.isEmpty,
              let note = noteTextView.text, note != notePlaceholder,
              let date = selectedDate else { return }

        let newDate = SpecialDate(title: title, date: date, note: note)
        DataStore.shared.specialDates.append(newDate)

        collectionView.reloadData()
        clearFields()
    }

    func clearFields() {
        titleField.text = ""
        dateField.text = ""
        noteTextView.text = notePlaceholder
        noteTextView.textColor = .placeholderText
        selectedDate = nil
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == dateField {
            openDatePicker()
            return false
        }
        return true
    }

    @IBAction func calendarTapped(_ sender: UIButton) {
        openDatePicker()
    }

    @objc func openDatePicker() {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels

        let alert = UIAlertController(title: "Select Date",
                                      message: "\n\n\n\n\n\n\n\n",
                                      preferredStyle: .actionSheet)

        alert.view.addSubview(picker)

        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            picker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 20)
        ])

        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            self.dateField.text = formatter.string(from: picker.date)
            self.selectedDate = picker.date
        })

        present(alert, animated: true)
    }

    func setupNotePlaceholder() {
        noteTextView.text = notePlaceholder
        noteTextView.textColor = .placeholderText
        noteTextView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 4)
        noteTextView.textContainer.lineFragmentPadding = 0
    }

    private func setupCollectionLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 12, left: 0, bottom: 24, right: 0)
        collectionView.collectionViewLayout = layout
    }

    func makeSeparator() -> UIView {
        let line = UIView()
        line.backgroundColor = .systemGray5
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }

    func addSeparators() {
        let divider1 = makeSeparator()
        let divider2 = makeSeparator()

        containerCell.addSubview(divider1)
        containerCell.addSubview(divider2)

        NSLayoutConstraint.activate([
            divider1.leadingAnchor.constraint(equalTo: containerCell.leadingAnchor, constant: 20),
            divider1.trailingAnchor.constraint(equalTo: containerCell.trailingAnchor, constant: -20),
            divider1.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 10),

            divider2.leadingAnchor.constraint(equalTo: containerCell.leadingAnchor, constant: 20),
            divider2.trailingAnchor.constraint(equalTo: containerCell.trailingAnchor, constant: -20),
            divider2.topAnchor.constraint(equalTo: dateField.bottomAnchor, constant: 10)
        ])
    }

    func monthsAgo(from date: Date) -> String {
        let components = Calendar.current.dateComponents([.month], from: date, to: Date())
        let months = components.month ?? 0

        if months <= 0 { return "This month" }
        if months == 1 { return "1 month ago" }
        return "\(months) months ago"
    }
}
extension SpecialDatesViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = notePlaceholder
            textView.textColor = .placeholderText
        }
    }
}
extension SpecialDatesViewController: UICollectionViewDelegate,
                                     UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataStore.shared.specialDates.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "SpecialDateCollectionCell",
            for: indexPath
        ) as! SpecialDateCollectionCell

        let data = DataStore.shared.specialDates[indexPath.item]

        cell.titleLabel.text = data.title
        cell.noteTextView.text = data.note

        let comps = Calendar.current.dateComponents([.day, .year], from: data.date)
        cell.dayLabel.text = "\(comps.day ?? 0)"

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        cell.monthLabel.text = formatter.string(from: data.date)

        cell.yearLabel.text = "\(comps.year ?? 0)"
        cell.timeLabel.text = monthsAgo(from: data.date)

        return cell
    }
}
extension SpecialDatesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 100)
    }
}

