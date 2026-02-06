import UIKit

class SpecialDateCollectionCell: UICollectionViewCell {

    @IBOutlet weak var cardview: UIView!
    @IBOutlet weak var dateImageView: UIImageView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()

        cardview.layer.cornerRadius = 10
        cardview.clipsToBounds = true

        noteTextView.isScrollEnabled = true
        noteTextView.isEditable = false
        noteTextView.isSelectable = false
        noteTextView.backgroundColor = .clear
        noteTextView.backgroundColor = .clear
        noteTextView.textContainerInset = .zero
        noteTextView.textContainer.lineFragmentPadding = 0
    }

}

