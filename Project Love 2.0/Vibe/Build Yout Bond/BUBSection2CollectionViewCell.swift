//
//  BUBSection2CollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 12/12/25.
//

import UIKit

class BUBSection2CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var trophyTitleLabel: UILabel!
    @IBOutlet weak var trophySubtitleLabel: UILabel!
    @IBOutlet weak var trophyImageView: UIImageView!
    @IBOutlet var circleView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
        configureCircle()
    }
    func configureCircle(){
        circleView.layer.cornerRadius = 80 / 2
        circleView.backgroundColor = UIColor(
            red: 224/255,
            green: 207/255,
            blue: 255/255,
            alpha: 1.0
        )
        circleView.layer.masksToBounds = true
        
        circleView.layer.borderColor = UIColor(
            red: 145/255,
            green: 38/255,
            blue: 255/255,
            alpha: 1.0
        ).cgColor
        circleView.layer.borderWidth = 2
    }
    func configureCells(bond : BuildYourBondpage){
        trophyTitleLabel.text = bond.badge.description
        trophySubtitleLabel.text = bond.badgesubHeading.description
        trophyImageView.image = UIImage(systemName: "trophy.fill")
        trophyImageView.tintColor = .gold
        
    }

}
