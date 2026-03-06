//
//  EmptyStateLoveNoteCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by shivangi mishra on 06/03/26.
//

import UIKit

class EmptyStateLoveNoteCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(title: String, subtitle: String, imageName: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        // Ensure image fits and scales properly
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: imageName)
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        
        // To deal with UICollectionViewFlowLayout.automaticSize
        let targetWidth = UIScreen.main.bounds.width - 24
        let targetSize = CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
        var size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        // Fallback since XIB lacks bottom constraint for exact sizing
        if size.height < 300 {
            size.height = 300
        }
        
        attributes.frame.size = CGSize(width: targetWidth, height: size.height)
        return attributes
    }
}
