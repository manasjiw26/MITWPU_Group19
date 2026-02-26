//
//  LNSentCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by shivangi mishra on 12/02/26.
//

import UIKit

class LNSentCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        backgroundColor = UIColor(named: "AppBackground") ?? .secondarySystemBackground
    }
  
    func configureCells(_ note: LoveNote) {
        let hasReaction = note.reaction != nil && !(note.reaction?.isEmpty ?? true)
        
        if note.status == .sent {
            if hasReaction {
                emojiLabel.text = note.reaction
                titleLabel.text = "Your partner shared their reaction"
            } else {
                emojiLabel.text = "👀"
                titleLabel.text = "Still waiting for their reaction"
            }
        }
        else if note.status == .received {
            if hasReaction {
                emojiLabel.text = note.reaction
                titleLabel.text = "You reacted to this note"
            } else {
                emojiLabel.text = "✍️"
                titleLabel.text = "Choose a reaction"
            }
        }
    }
}
