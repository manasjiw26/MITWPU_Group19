//
//  CustomCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 06/01/26.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
        
        // Initialization code
    }
    func configureCells(imageName: String, title: String, subtitle: String) {
        imageView.image = UIImage(named: imageName)
        label.text = title
        subtitleLabel.text = subtitle
    }
   
}
