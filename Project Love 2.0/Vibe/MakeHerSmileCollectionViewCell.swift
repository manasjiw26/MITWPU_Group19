//
//  MakeHerSmileCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class MakeHerSmileCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    private let wScale = UIScreen.main.bounds.width / 393.0

    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = 19 * wScale
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
        
    }
    
    func configureCell(item: MakeSmile) {
        let config = UIImage.SymbolConfiguration(weight: .bold)
        imageView.image = UIImage(systemName: item.imageName, withConfiguration: config)
        imageView.tintColor = UIColor(red: 0.50, green: 0.39, blue: 0.71, alpha: 1.0)
        titleLabel.text = item.types
        titleLabel.font = UIFont.systemFont(ofSize: 14 * wScale, weight: .semibold)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
    }

}
