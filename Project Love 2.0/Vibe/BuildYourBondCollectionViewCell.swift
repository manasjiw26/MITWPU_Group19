//
//  BuildYourBondCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class BuildYourBondCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var BackgroundImage : UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
    func configureCell(bond : BuildYourBond) {
        imageView.image = UIImage(named: bond.imageName)
        titleLabel.text = bond.name
        BackgroundImage.image = UIImage(named : "BUBBackround")
    }

}
