import UIKit

protocol LNReceiveCellDelegate: AnyObject {
    func didSelectEmoji(_ emoji: String, for note: LoveNote)
}

class LNReceiveCollectionViewCell: UICollectionViewCell {
    
    var currentNote: LoveNote?
    private let emojis = ["❤️", "😍", "🥰", "😘", "💖", "🔥"]
    weak var delegate: LNReceiveCellDelegate?

    @IBOutlet var reactionView: [UIView]!
    @IBOutlet var reactionLabel: [UILabel]!

    override func awakeFromNib() {
        super.awakeFromNib()
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
        let chosenEmoji = emojis[index]
        note.reaction = chosenEmoji
        self.currentNote = note
        
        updateSelectionUI(selectedIndex: index)
        delegate?.didSelectEmoji(chosenEmoji, for: note)
    }
    
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

        // Highlight existing reaction
        if let existingReaction = note.reaction, let index = emojis.firstIndex(of: existingReaction) {
            updateSelectionUI(selectedIndex: index)
        }
        
        // Set Emoji Labels
        for (index, label) in reactionLabel.enumerated() {
            if index < emojis.count {
                label.text = emojis[index]
            }
        }
    }
}
