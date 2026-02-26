import UIKit

class EmojiItemCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var emojiLabel: UILabel!

    private let figmaPurple = UIColor(
        red: 0.61,
        green: 0.45,
        blue: 0.89,
        alpha: 1.0
    )

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
        containerView.backgroundColor = UIColor.systemGray6

        emojiLabel.font = UIFont.systemFont(ofSize: 28)
        emojiLabel.textAlignment = .center
    }

    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.18) {
                // Reduced scale from 1.08 to 1.04 so it doesn't overlap neighbors too much
                self.transform = self.isSelected
                    ? CGAffineTransform(scaleX: 1.04, y: 1.04)
                    : .identity
            }

            if isSelected {
                containerView.layer.borderWidth = 2
                containerView.layer.borderColor = figmaPurple.cgColor
                containerView.backgroundColor = figmaPurple.withAlphaComponent(0.12)
                // Bring selected cell to front so it doesn't go behind others
                self.superview?.bringSubviewToFront(self)
            } else {
                containerView.layer.borderWidth = 1
                containerView.layer.borderColor = UIColor.systemGray4.cgColor
                containerView.backgroundColor = UIColor.systemGray6
            }
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
    }

    func configure(with emoji: String) {
        emojiLabel.text = emoji
    }
}
