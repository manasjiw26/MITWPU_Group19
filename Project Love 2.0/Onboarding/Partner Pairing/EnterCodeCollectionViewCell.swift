//
//  EnterCodeCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class EnterCodeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bgView: UIView!
    
    
    @IBOutlet weak var enterCodeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.layer.cornerRadius = 12
        bgView.layer.masksToBounds = true
    }

}
