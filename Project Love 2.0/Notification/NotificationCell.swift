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
        setupConstraints()
    }

    private func setupUI() {
        cardView.layer.cornerRadius = 16
               cardView.layer.shadowColor = UIColor.black.cgColor
               cardView.layer.shadowOpacity = 0.06
               cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
               cardView.layer.shadowRadius = 10

               iconContainerView.layer.cornerRadius = 12
               iconContainerView.backgroundColor = .systemGray6

               leftAccentView.layer.cornerRadius = 3

               titleLabel.font = .boldSystemFont(ofSize: 14)
               messageLabel.font = .systemFont(ofSize: 13)
               messageLabel.numberOfLines = 2
               timeLabel.font = .systemFont(ofSize: 11)
               timeLabel.textColor = .secondaryLabel
    }
    
    private func setupConstraints() {
            [cardView, leftAccentView, iconContainerView,
             iconImageView, titleLabel, messageLabel, timeLabel]
                .forEach { $0?.translatesAutoresizingMaskIntoConstraints = false }

            NSLayoutConstraint.activate([

                // cardView
                cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

                // leftAccentView
                leftAccentView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
                leftAccentView.topAnchor.constraint(equalTo: cardView.topAnchor),
                leftAccentView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
                leftAccentView.widthAnchor.constraint(equalToConstant: 6),

                // iconContainerView
                iconContainerView.leadingAnchor.constraint(equalTo: leftAccentView.trailingAnchor, constant: 12),
                iconContainerView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
                iconContainerView.widthAnchor.constraint(equalToConstant: 40),
                iconContainerView.heightAnchor.constraint(equalToConstant: 40),

                // iconImageView
                iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
                iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
                iconImageView.widthAnchor.constraint(equalToConstant: 20),
                iconImageView.heightAnchor.constraint(equalToConstant: 20),

                // titleLabel
                titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
                titleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 12),
                titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

                // messageLabel
                messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                messageLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

                // timeLabel
                timeLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 6),
                timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                timeLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -16)
            ])
        }

    func configure(with notification: AppNotification) {
        titleLabel.text = notification.titleText
        messageLabel.text = "\(notification.senderName) \(notification.message)"
        timeLabel.text = notification.timeAgoText
        iconImageView.image = UIImage(systemName: notification.iconName)
    }

}




