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
    
    private let wScale = UIScreen.main.bounds.width / 393.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 0
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
        
        titleLabel.font = UIFont.systemFont(ofSize: 18 * wScale, weight: .semibold)
    }

}
