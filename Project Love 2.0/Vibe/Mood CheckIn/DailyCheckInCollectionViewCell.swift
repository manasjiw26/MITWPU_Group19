//
//  DailyCheckInCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class DailyCheckInCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var checkInImageView: UIImageView!
    @IBOutlet weak var checkInTitleLabel: UILabel!
    @IBOutlet weak var checkInSubTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Card appearance
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = false
        self.backgroundColor = UIColor(red: 168/255, green: 171/255,  blue: 222/255, alpha: 0.6)

        // Initialization code
    }
func configureCells(){
        checkInTitleLabel.text = "Daily Check-In"
        checkInSubTitleLabel.text = "Get personalised exercises based on your relationship"
        checkInImageView.image = UIImage(named: "DailyCheckIn")
    }
}


