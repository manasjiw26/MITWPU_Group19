//
//  ActivityStatsCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

class ActivityStatsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var StatstitleLabel: UILabel!
    @IBOutlet weak var StatsCountLabel: UILabel!
    @IBOutlet weak var StatsImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = 19
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
        // Initialization code
    }
    func configureCell(item: ActivityStats) {
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        StatsImageView.image = UIImage(systemName: item.imageName,withConfiguration: config)
        StatsImageView.tintColor = UIColor(red: 0.50, green: 0.39, blue: 0.71, alpha: 1.0)
        StatstitleLabel.text = item.types
        StatsCountLabel.text = "\(item.count)"
        
    }
}
