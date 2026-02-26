import UIKit

class LoveNoteDetail2ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var note: LoveNote?
    var onDismiss: (() -> Void)?
    
    private var originalDate: Date?
    private var originalReaction: String?
    private var actionHeightConstraint: NSLayoutConstraint?

    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var headerDate: UILabel!
    @IBOutlet weak var checkmarkButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        
        originalReaction = note?.reaction
        originalDate = note?.scheduledDate
        
        // Registering cells
        collectionView.register(UINib(nibName: "LNSentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LNSentCollectionViewCell")
        collectionView.register(UINib(nibName: "LNReceiveCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LNReceiveCollectionViewCell")
        collectionView.register(UINib(nibName: "LNScheduleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LNScheduleCollectionViewCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.layer.cornerRadius = 10
        
        setupCheckmarkUI()
        configureHeader()
        configureMessage()
        
        if let note = note {
            updateActionHeight()
            collectionView.collectionViewLayout = generateLayout(for: note)
        }
        setupSheet()
    }
    
    private func setupCheckmarkUI() {
        checkmarkButton.setTitle("", for: .normal)
        checkmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill",
                                         withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)), for: .normal)
        checkmarkButton.tintColor = .systemGreen
        checkmarkButton.isHidden = true
    }

    private func updateActionHeight() {
        guard let note = note else { return }
        actionHeightConstraint?.isActive = false
        
        let height: CGFloat
        if note.status == .received && note.reaction != nil {
            height = 120
        } else {
            switch note.status {
            case .received: height = 160
            case .sent:     height = 120
            case .scheduled: height = 130
            }
        }
        
        actionHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: height)
        actionHeightConstraint?.isActive = true
    }

    private func generateLayout(for note: LoveNote) -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width - 36
        let height: CGFloat = (note.status == .received && note.reaction == nil) ? 160 : 120
        layout.itemSize = CGSize(width: width, height: height)
        return layout
    }

    private func configureHeader() {
        guard let note = note else { return }
        headerTitle.text = note.status.displayText
        headerDate.text = (note.status == .scheduled) ? note.scheduledFullDateText : note.timeText
    }

    private func configureMessage() {
        messageLabel.text = note?.message
    }

    private func setupLayout() {
        [headerTitle, headerDate, checkmarkButton, messageLabel, collectionView].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let note = note else { return UICollectionViewCell() }
        
        if note.status == .received && note.reaction != nil {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LNSentCollectionViewCell", for: indexPath) as! LNSentCollectionViewCell
            cell.configureCells(note)
            return cell
        }

        let id: String = {
            switch note.status {
            case .sent: return "LNSentCollectionViewCell"
            case .received: return "LNReceiveCollectionViewCell"
            case .scheduled: return "LNScheduleCollectionViewCell"
            }
        }()
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath)
        
        if let scheduleCell = cell as? LNScheduleCollectionViewCell {
            scheduleCell.configureCells(with: note, isEditing: true)
            scheduleCell.delegate = self
        } else if let receiveCell = cell as? LNReceiveCollectionViewCell {
            receiveCell.configureCells(with: note)
            receiveCell.delegate = self
        } else if let sentCell = cell as? LNSentCollectionViewCell {
            sentCell.configureCells(note)
        }
        return cell
    }

    @IBAction func editTapped(_ sender: UIButton) {
        submitData()
    }
    
    private func submitData() {
        guard let updatedNote = self.note else { return }
        
        if let reaction = updatedNote.reaction, reaction != originalReaction {
            DataStore.shared.setReaction(reaction, for: updatedNote)
        }
        
        if updatedNote.scheduledDate != originalDate {
            if let newDate = updatedNote.scheduledDate {
                // Fixed: Matches the method name in your DataStore.swift file
                DataStore.shared.didUpdateDate(for: updatedNote, to: newDate)
            }
        }
        
        self.onDismiss?()
        self.dismiss(animated: true)
    }

    private func setupSheet() {
        if let sheet = sheetPresentationController {
            sheet.detents = [.custom { _ in return self.calculateSheetHeight() }]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
    }

    private func calculateSheetHeight() -> CGFloat {
        view.layoutIfNeeded()
        let maxWidth = view.bounds.width - 40
        let messageSize = messageLabel.systemLayoutSizeFitting(
            CGSize(width: maxWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel
        )
        let headerHeight = headerDate.frame.maxY
        let actionHeight = actionHeightConstraint?.constant ?? 0
        return headerHeight + 24 + messageSize.height + 28 + actionHeight + 40
    }
}

extension LoveNoteDetail2ViewController: LNScheduleCellDelegate {
    func requestPickerPresentation(_ alert: UIAlertController) {
        self.present(alert, animated: true)
    }

    func didUpdateDate(for note: LoveNote, to newDate: Date) {
        self.note?.scheduledDate = newDate
        configureHeader()
        
        let hasChanged = newDate != originalDate
        checkmarkButton.isHidden = !hasChanged
        
        updateActionHeight()
        sheetPresentationController?.invalidateDetents()
    }
}

extension LoveNoteDetail2ViewController: LNReceiveCellDelegate {
    func didSelectEmoji(_ emoji: String, for note: LoveNote) {
        self.note?.reaction = emoji
        DataStore.shared.setReaction(emoji, for: self.note!)
        
        UIView.animate(withDuration: 0.3) {
            self.updateActionHeight()
            self.collectionView.reloadSections(IndexSet(integer: 0))
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.onDismiss?()
            self.dismiss(animated: true)
        }
    }
}
