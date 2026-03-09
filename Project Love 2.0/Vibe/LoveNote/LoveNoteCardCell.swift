//
//  LoveNoteCardCell.swift
//  Project Love 2.0
//

import UIKit

class LoveNoteCardCell: UICollectionViewCell {

    @IBOutlet weak var verticalStackView: UIStackView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var reactionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

   
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        verticalStackView.axis = .vertical
        verticalStackView.alignment = .fill
        verticalStackView.spacing = 8
        messageLabel.numberOfLines = 2
        messageLabel.lineBreakMode = .byTruncatingTail
        reactionLabel.numberOfLines = 1
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    


    func configure(with note: LoveNote) {

        messageLabel.text = note.message
        statusLabel.text = note.status.displayText

        switch note.status {

        case .scheduled:
            timeLabel.text = note.scheduledRelativeText
            reactionLabel.text = note.scheduledFullDateText
            reactionLabel.textColor = .secondaryLabel
            dividerView.isHidden = false

        case .sent:
            timeLabel.text = note.timeText

            if let reaction = note.reaction {
                reactionLabel.text = "She reacted \(reaction)"
                reactionLabel.textColor = .secondaryLabel
            } else {
                reactionLabel.text = "Waiting for a reaction"
                reactionLabel.textColor = .secondaryLabel
            }

            dividerView.isHidden = false

        case .received, .loveTipCompleted:
            timeLabel.text = note.timeText

            if let reaction = note.reaction {
                reactionLabel.text = "You reacted \(reaction)"
                reactionLabel.textColor = .secondaryLabel
            } else {
                reactionLabel.text = "Reaction pending"
                reactionLabel.textColor = .secondaryLabel
            }

            dividerView.isHidden = false
        }
    }


}
