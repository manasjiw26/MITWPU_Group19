//
//  MemoryGridCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 17/12/25.
//

import UIKit

class MemoryGridCell: UICollectionViewCell {
    
    
    @IBOutlet weak var ImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ImageView.layer.masksToBounds = true
    }
}
