//
//  BUBSection3CollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

class BUBSection3CollectionViewCell: UICollectionViewCell {
    @IBOutlet var stepLabel: [UILabel]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
    func configureCells(bond : BuildYourBondpage){
        for i in 0..<bond.HIWStep.count {
            stepLabel[i].text = bond.HIWStep[i].description
        }
        
    }
}
