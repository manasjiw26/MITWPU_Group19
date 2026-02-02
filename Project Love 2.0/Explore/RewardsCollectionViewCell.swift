//
//  RewardsCollectionViewCell.swift
//  Project LOVE
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

class RewardsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var rewardImageView: UIImageView!
    @IBOutlet weak var rewardTitleLabel: UILabel!

    override func layoutSubviews() {
           super.layoutSubviews()
           
        rewardImageView.layer.cornerRadius = rewardImageView.frame.height / 2
        rewardImageView.clipsToBounds = true
//        rewardImageView.layer.borderColor = UIColor(
//            red: 75/255,    // R
//            green: 4/255,   // G
//            blue: 150/255,  // B
//            alpha: 1
//        ).cgColor
//        rewardImageView.layer.borderWidth = 0.5

       }
    
    
    func configureCell(reward: Reward) {
        rewardImageView.image = UIImage(named: reward.image)
        rewardTitleLabel.text = reward.name

    }

}
