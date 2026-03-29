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

    override func awakeFromNib() {
        super.awakeFromNib()
        rewardImageView.contentMode = .scaleAspectFit
        rewardImageView.backgroundColor = .systemGray6
        rewardImageView.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        rewardImageView.layer.cornerRadius = rewardImageView.bounds.height / 2
    }
    
    func configureCell(reward: Reward) {
        if let originalInfo = UIImage(named: reward.image) {
            rewardImageView.image = originalInfo.withPadding(15)
        } else {
            rewardImageView.image = nil
        }
        rewardTitleLabel.text = reward.name
    }
}

extension UIImage {
    func withPadding(_ padding: CGFloat) -> UIImage? {
        let maxDim = max(self.size.width, self.size.height)
        let newSize = CGSize(width: maxDim + padding * 2, height: maxDim + padding * 2)
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let origin = CGPoint(x: (newSize.width - self.size.width) / 2, y: (newSize.height - self.size.height) / 2)
        self.draw(at: origin)
        let paddedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return paddedImage
    }

}
