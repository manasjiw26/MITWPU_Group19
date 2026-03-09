//
//  memoryEmptyStateCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 09/03/26.
//

import UIKit

class memoryEmptyStateCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var emptyTitleLabel: UILabel!

        override func awakeFromNib() {
            super.awakeFromNib()
        }
    func configure() {
            emptyTitleLabel.text = "No memory"
            emptyImageView.image = UIImage(named: "empty_memory")
        }
}
