//
//  StepsTableViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 12/12/25.
//

import UIKit

class StepsTableViewCell: UITableViewCell {
   
    
    @IBOutlet var cardBackground: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

            cardBackground.layer.cornerRadius = 16
            cardBackground.backgroundColor = .white
            cardBackground.layer.masksToBounds = true
            layer.masksToBounds = false

            backgroundColor = .clear
            contentView.backgroundColor = .clear
            selectionStyle = .none
        }

    func configure(with step: StepsToFollow, isExpanded: Bool) {

        if isExpanded {

            let full = NSMutableAttributedString()

            // bold title
            let title = NSAttributedString(
                string: "\(step.number). \(step.title): ",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 17, weight: .medium),
                    .foregroundColor: UIColor.label
                ])

            // normal description
            let desc = NSAttributedString(
                string: step.descriptionLabel,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 17, weight: .regular),
                    .foregroundColor: UIColor.label
                ])

            full.append(title)
            full.append(desc)

            titleLabel.attributedText = full

        } else {

            titleLabel.text = "\(step.number). \(step.title)"
            titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }

        // shadow glow logic stays same
        if isExpanded {
            layer.shadowColor = UIColor(
                red: 128/255,
                green: 99/255,
                blue: 181/255,
                alpha: 1
            ).cgColor
            layer.shadowOpacity = 0.7
            layer.shadowOffset = CGSize(width: 0, height: 4)
            layer.shadowRadius = 2
        } else {
            layer.shadowOpacity = 0
        }
    }

}
