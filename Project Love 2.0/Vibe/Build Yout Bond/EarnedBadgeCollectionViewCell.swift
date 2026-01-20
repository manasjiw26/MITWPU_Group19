//
//  EarnedBadgeCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by shivangi mishra on 20/01/26.
//

import UIKit

class EarnedBadgeCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var badgeImageView: UIImageView!
    
    @IBOutlet weak var badgeTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .white
    }

    
    func configure(bond: BuildYourBondpage) {
         badgeTitleLabel.text = bond.badge
         badgeImageView.image = UIImage(
            named: bond.badgeImageName
        )
     }
}
