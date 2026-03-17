import UIKit
import Supabase

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

        setupNotePlaceholder()
        addSeparators()
        setupCollectionLayout()   // uses list config with swipe-to-delete
        registerCells()

        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false

        loadSpecialDatesFromSupabase()
        listenForRealtimeChanges()
    }

    private func registerCells() {
        collectionView.register(
            UINib(nibName: "SpecialDateCollectionCell", bundle: nil),
            forCellWithReuseIdentifier: "SpecialDateCollectionCell"
        )
        collectionView.register(
            UINib(nibName: "EmptyStateCollectioViewCellCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "empty_cell"
        )
    }

    // MARK: - Collection Layout with Swipe-to-Delete

    private func setupCollectionLayout() {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.backgroundColor = .clear

        // Native iOS swipe-to-delete
        listConfig.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self,
                  !DataStore.shared.specialDates.isEmpty else { return nil }

            let deleteAction = UIContextualAction(
                style: .destructive,
                title: "Delete"
            ) { [weak self] _, _, completion in
                guard let self = self else { completion(false); return }
                let specialDate = DataStore.shared.specialDates[indexPath.item]
                self.deleteSpecialDate(specialDate, at: indexPath)
                completion(true)
            }
            deleteAction.image = UIImage(systemName: "trash.fill")
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }

        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.delegate   = self
        collectionView.dataSource = self
    }

    // MARK: - Supabase Fetch

    private func loadSpecialDatesFromSupabase() {
        guard let relationshipId = DataStore.shared.currentRelationshipId else { return }

        Task { @MainActor in
            do {
                let rows = try await SupabaseManager.shared.fetchSpecialDates(relationshipId: relationshipId)
                DataStore.shared.specialDates = rows.map { row in
                    let eventDate = Self.parseEventDate(row.event_date) ?? Date()
                    return SpecialDate(
                        id: row.special_date_id,
                        relationshipId: row.relationship_id,
                        userId: row.user_id,
                        title: row.title,
                        date: eventDate,
                        note: row.note ?? "",
                        createdAt: row.created_at
                    )
                }
                collectionView.reloadData()
            } catch {
                print("Failed to load special dates: \(error)")
            }
        }
    }

    private static func parseEventDate(_ raw: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for format in ["yyyy-MM-dd", "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX", "yyyy-MM-dd'T'HH:mm:ssXXXXX"] {
            formatter.dateFormat = format
            if let d = formatter.date(from: raw) { return d }
        }
        return nil
    }

    // MARK: - Realtime

    private func listenForRealtimeChanges() {
        guard let relationshipId = DataStore.shared.currentRelationshipId else { return }
        SupabaseManager.shared.listenForSpecialDateChanges(relationshipId: relationshipId) { [weak self] in
            self?.loadSpecialDatesFromSupabase()
        }
    }

    // MARK: - Save

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let titleText = titleField.text, !titleText.isEmpty,
              let noteText = noteTextView.text, noteText != notePlaceholder,
              let date = selectedDate else { return }

        guard let relationshipId = DataStore.shared.currentRelationshipId,
              let userId = DataStore.shared.currentUserId else { return }

        let isoFormatter = DateFormatter()
        isoFormatter.locale = Locale(identifier: "en_US_POSIX")
        isoFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = isoFormatter.string(from: date)

        let insert = SpecialDateInsert(
            relationship_id: relationshipId.uuidString,
            user_id: userId.uuidString,
            title: titleText,
            event_date: dateString,
            note: noteText
        )

        Task { @MainActor in
            do {
                let dbRow = try await SupabaseManager.shared.insertSpecialDate(insert)
                let eventDate = Self.parseEventDate(dbRow.event_date) ?? date
                let newSpecialDate = SpecialDate(
                    id: dbRow.special_date_id,
                    relationshipId: dbRow.relationship_id,
                    userId: dbRow.user_id,
                    title: dbRow.title,
                    date: eventDate,
                    note: dbRow.note ?? "",
                    createdAt: dbRow.created_at
                )
                DataStore.shared.specialDates.append(newSpecialDate)
                collectionView.reloadData()
                clearFields()
            } catch {
                print("Failed to save special date: \(error)")
            }
        }
    }

    // MARK: - Delete

    private func deleteSpecialDate(_ specialDate: SpecialDate, at indexPath: IndexPath) {
        Task { @MainActor in
            do {
                try await SupabaseManager.shared.deleteSpecialDate(specialDateId: specialDate.id)
                DataStore.shared.specialDates.remove(at: indexPath.item)
                collectionView.reloadData()
            } catch {
                print("Failed to delete special date: \(error)")
                let alert = UIAlertController(
                    title: "Error",
                    message: "Could not delete. Please try again.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        }
    }

    // MARK: - Helpers

    func clearFields() {
        titleField.text = ""
        dateField.text = ""
        noteTextView.text = notePlaceholder
        noteTextView.textColor = .placeholderText
        selectedDate = nil
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == dateField { openDatePicker(); return false }
        return true
    }

    @IBAction func calendarTapped(_ sender: UIButton) { openDatePicker() }

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
        let months = Calendar.current.dateComponents([.month], from: date, to: Date()).month ?? 0
        if months <= 0 { return "This month" }
        if months == 1 { return "1 month ago" }
        return "\(months) months ago"
    }
}

// MARK: - UITextViewDelegate
extension SpecialDatesViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = ""; textView.textColor = .label
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = notePlaceholder; textView.textColor = .placeholderText
        }
    }
}

// MARK: - UICollectionViewDataSource + Delegate
extension SpecialDatesViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = DataStore.shared.specialDates.count
        return count == 0 ? 1 : count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let items = DataStore.shared.specialDates

        if items.isEmpty {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "empty_cell", for: indexPath
            ) as! EmptyStateCollectioViewCellCollectionViewCell
            cell.configure(title: "No dates added yet", subtitle: "add now", imageName: "empty_dates")
            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "SpecialDateCollectionCell", for: indexPath
        ) as! SpecialDateCollectionCell

        let data = items[indexPath.item]
        cell.titleLabel.text = data.title
        cell.noteTextView.text = data.note

        let comps = Calendar.current.dateComponents([.day, .year], from: data.date)
        cell.dayLabel.text = "\(comps.day ?? 0)"
        cell.yearLabel.text = "\(comps.year ?? 0)"

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        cell.monthLabel.text = formatter.string(from: data.date)
        cell.timeLabel.text  = monthsAgo(from: data.date)

        return cell
    }
}
