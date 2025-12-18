//
//  MemoryLaneCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 16/12/25.
//

import UIKit

class MemoryLaneCell: UICollectionViewCell {
    
    
    @IBOutlet weak var ImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ImageView.layer.cornerRadius = 5
        ImageView.layer.masksToBounds = true
    }
}
