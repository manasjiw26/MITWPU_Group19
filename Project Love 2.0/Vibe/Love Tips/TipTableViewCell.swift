//
//  TipTableViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class TipTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var optionLabel: UILabel!
    
    @IBOutlet weak var radioButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
  
        contentView.backgroundColor = .appBackground
              
        //to avoid weird button tint effect
        radioButton.adjustsImageWhenHighlighted = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
       
        }
    
    func configure(option: String, isSelected: Bool) {
        optionLabel.text = option
        
        let imageName = isSelected ? "largecircle.fill.circle" : "circle"
        radioButton.setImage(UIImage(systemName: imageName), for: .normal)

        // Configure the view for the selected state
    }

}
