//
//  EmptyStateCollectioViewCellCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class EmptyStateCollectioViewCellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var emptyImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

        

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(title: String, subtitle: String, imageName: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        emptyImageView.image = UIImage(named: imageName)
    }

}
