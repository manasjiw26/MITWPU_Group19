//
//  OptionTableViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class OptionTableViewCell: UITableViewCell {

    
    @IBOutlet weak var optionLabel: UILabel!
    
    @IBOutlet weak var radioImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
           contentView.backgroundColor = .white
           backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(option: String, isSelected: Bool) {
           optionLabel.text = option

           if isSelected {
               radioImageView.image = UIImage(systemName: "largecircle.fill.circle")
           } else {
               radioImageView.image = UIImage(systemName: "circle")
           }
       }

}
