//
//  ActivityCollectionViewCell.swift
//  Project LOVE
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

class ActivityCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var activityImageView: UIImageView!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var activityDescriptionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
    }
    func configureCell(activityCategory: ActivityCategory) {
        activityNameLabel.text = activityCategory.name
        activityDescriptionLabel.text = activityCategory.description
        activityImageView.image = UIImage(named: activityCategory.image)
        
    }

}
