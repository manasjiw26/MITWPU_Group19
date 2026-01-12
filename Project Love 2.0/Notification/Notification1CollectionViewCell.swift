//
//  Notification1CollectionViewCell.swift
//  Project Love 2.0
//
//  Created by shivangi mishra on 11/01/26.
//

import UIKit

class Notification1CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var notificationBackgroundView: UIView!
    @IBOutlet var notificationImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var notificationDateLabel: UILabel!
    @IBOutlet weak var notificationDescLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        notificationBackgroundView.layer.cornerRadius = 10
        notificationBackgroundView.layer.masksToBounds = true
        notificationView.layer.cornerRadius = 10
        notificationView.layer.masksToBounds = true
        
    }
    

        func configure(with notification: AppNotification) {
            notificationImageView.layer.cornerRadius = 5
            titleLabel.text = notification.titleText
            notificationDescLabel.text = "\(notification.senderName) \(notification.message)"
            notificationDateLabel.text = notification.timeAgoText
            notificationImageView.image = UIImage(systemName: notification.iconName)
            
            
            //Visual representation of read state
            notificationBackgroundView.alpha = notification.isRead ? 0.6 : 1.0
        }


}
