import UIKit

protocol LNReceiveCellDelegate: AnyObject {
    func didSelectEmoji(_ emoji: String, for note: LoveNote)
    func requestEmojiKeyboard(from cell: LNReceiveCollectionViewCell)
}

// MARK: - Custom UITextField that forces the emoji keyboard
class EmojiTextField: UITextField {
    override var textInputMode: UITextInputMode? {
        return UITextInputMode.activeInputModes.first(where: { $0.primaryLanguage == "emoji" })
            ?? super.textInputMode
    }
}

class LNReceiveCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    var currentNote: LoveNote?
    // Only 5 preset emojis; the 6th slot is the "+" emoji keyboard button
    private let emojis = ["❤️", "😍", "🥰", "😘", "💖"]
    weak var delegate: LNReceiveCellDelegate?

    @IBOutlet var reactionView: [UIView]!
    @IBOutlet var reactionLabel: [UILabel]!
    
    // Hidden text field used to trigger the emoji keyboard
    private lazy var emojiTextField: EmojiTextField = {
        let tf = EmojiTextField()
        tf.delegate = self
        tf.alpha = 0
        tf.autocorrectionType = .no
        tf.keyboardType = .default
        return tf
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(emojiTextField)
        setupTapGestures()
    }
    
    private func setupTapGestures() {
        for (index, view) in reactionView.enumerated() {
            view.isUserInteractionEnabled = true
            view.tag = index
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleEmojiTap(_:)))
            view.addGestureRecognizer(tap)
        }
    }
    
    @objc private func handleEmojiTap(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view, var note = currentNote else { return }
        
        let index = tappedView.tag
        
        // Index 5 = "+" button → open emoji keyboard
        if index == 5 {
            openEmojiKeyboard()
            return
        }
        
        let chosenEmoji = emojis[index]
        note.reaction = chosenEmoji
        self.currentNote = note
        
        updateSelectionUI(selectedIndex: index)
        delegate?.didSelectEmoji(chosenEmoji, for: note)
    }
    
    // MARK: - Emoji Keyboard
    private func openEmojiKeyboard() {
        emojiTextField.text = ""
        emojiTextField.becomeFirstResponder()
    }
    
    // UITextFieldDelegate: capture the first emoji character typed
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard !string.isEmpty, var note = currentNote else { return false }
        
        // Take just the first emoji/character
        let emoji = String(string.unicodeScalars.prefix(2))
            .trimmingCharacters(in: .whitespaces)
        guard !emoji.isEmpty else { return false }
        
        note.reaction = emoji
        self.currentNote = note
        
        emojiTextField.resignFirstResponder()
        
        // Highlight the "+" slot (index 5) to indicate a custom emoji was chosen
        updateSelectionUI(selectedIndex: 5)
        // Show the chosen emoji in the "+" label
        if let plusLabel = reactionLabel.first(where: { $0.tag == 5 }) {
            plusLabel.text = emoji
        }
        
        delegate?.didSelectEmoji(emoji, for: note)
        return false
    }
    
    // MARK: - Selection UI
    private func updateSelectionUI(selectedIndex: Int) {
        let purplishColor = UIColor.systemPurple
        for (index, view) in reactionView.enumerated() {
            if index == selectedIndex {
                view.backgroundColor = purplishColor.withAlphaComponent(0.15)
                view.layer.borderWidth = 1.5
                view.layer.borderColor = purplishColor.cgColor
            } else {
                view.backgroundColor = .white
                view.layer.borderWidth = 0
            }
        }
    }
    
    func configureCells(with note: LoveNote) {
        self.currentNote = note
        
        // Reset styles
        for view in reactionView {
            view.backgroundColor = .white
            view.layer.cornerRadius = 12
            view.layer.borderWidth = 0
        }
        
        // Set preset emoji labels (indices 0-4)
        for (index, label) in reactionLabel.enumerated() {
            label.tag = index
            if index < emojis.count {
                label.text = emojis[index]
            } else if index == 5 {
                // Default "+" for the emoji keyboard button; will be replaced by chosen emoji
                label.text = "+"
            }
        }

        // Highlight existing reaction
        if let existingReaction = note.reaction {
            if let index = emojis.firstIndex(of: existingReaction) {
                // It's one of the presets
                updateSelectionUI(selectedIndex: index)
            } else {
                // It's a custom emoji chosen from the keyboard — highlight slot 5 and show it
                updateSelectionUI(selectedIndex: 5)
                if let plusLabel = reactionLabel.first(where: { $0.tag == 5 }) {
                    plusLabel.text = existingReaction
                }
            }
        }
    }
}

