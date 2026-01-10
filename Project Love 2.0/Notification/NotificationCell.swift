//
//  NotificationCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 10/01/26.
//

import UIKit

class NotificationCell: UICollectionViewCell {
    
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var leftAccentView: UIView!
    
    @IBOutlet weak var iconContainerView: UIView!
    
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBOutlet weak var messageLabel: UILabel!
    
    
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = false

        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 10

        iconContainerView.layer.cornerRadius = 12

        leftAccentView.layer.cornerRadius = 8
        leftAccentView.layer.maskedCorners = [
            .layerMaxXMinYCorner,
            .layerMaxXMaxYCorner
        ]
    }

    func configure(with notification: AppNotification) {
        titleLabel.text = notification.typeText
        messageLabel.text = notification.message
        timeLabel.text = notification.timeAgo
    }

}
