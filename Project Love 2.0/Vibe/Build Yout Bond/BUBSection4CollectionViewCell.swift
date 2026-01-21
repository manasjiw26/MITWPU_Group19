//
//  BUBSection4CollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 12/12/25.
//

import UIKit

class BUBSection4CollectionViewCell: UICollectionViewCell {

    @IBOutlet var lockView : UIView!
    @IBOutlet var ActivityTitleLabel : UILabel!
    @IBOutlet var ActivitydescriptionLabel : UILabel!
    @IBOutlet var ActivityimageView : UIImageView!
    @IBOutlet var ActivityView : UIView!
    @IBOutlet var separatorImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
 
    func configureCells( activity: Activity,
                         index: Int,
                         total: Int,
                         activities: [Activity]) {
        
            ActivityTitleLabel.text = "Level \(index + 1): \(activity.name)"
            ActivitydescriptionLabel.text = activity.description
            ActivityimageView.image = UIImage(named: activity.image)

            separatorImageView.image = UIImage(named: "SeparatorImage")
            separatorImageView.isHidden = index == total - 1
        
            ActivityView.layer.cornerRadius = 10

            let isLocked: Bool

            if index == 0 {
                // First activity is always unlocked
                isLocked = false
            } else {
                // Locked ONLY if previous is not completed
                isLocked = activities[index - 1].status != .completed
            }

            lockView.isHidden = !isLocked
            let alpha: CGFloat = isLocked ? 0.5 : 1.0

            ActivityimageView.alpha = alpha
            ActivityTitleLabel.alpha = alpha
            ActivitydescriptionLabel.alpha = alpha
            ActivityView.backgroundColor = isLocked ? .systemGray4 : .white

    
    }
}
