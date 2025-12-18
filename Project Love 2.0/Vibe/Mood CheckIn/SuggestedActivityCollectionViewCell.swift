//
//  SuggestedActivityCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by anchal munot on 17/12/25.
//

import UIKit

class SuggestedActivityCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var suggestedActivityImageView: UIImageView!
    @IBOutlet weak var suggestedActivityNameLabel: UILabel!
    @IBOutlet weak var suggestedActivityDescriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
    }
    
    func configureCells(activity: Activity) {
        suggestedActivityNameLabel.text = activity.name
        suggestedActivityDescriptionLabel.text = activity.description
        suggestedActivityImageView.image = UIImage(named: activity.image)
        
    }
}
