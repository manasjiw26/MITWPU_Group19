//
//  ShareCodeCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class ShareCodeCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var bgView: UIView!
    
    
    @IBOutlet weak var CodeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // styling done here
                bgView.layer.cornerRadius = 12
                bgView.layer.masksToBounds = true
       
    }

}
