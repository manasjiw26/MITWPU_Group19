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
       
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        // This syncs the cell's opacity with the layout attributes
        // effectively fixing the "faded first card" bug.
        self.contentView.alpha = layoutAttributes.alpha
    }
    func configureCell(bond : BuildYourBond) {
        imageView.image = UIImage(named: bond.imageName)
        titleLabel.text = bond.name
        BackgroundImage.image = UIImage(named : "BUBBackround")
    }

}
