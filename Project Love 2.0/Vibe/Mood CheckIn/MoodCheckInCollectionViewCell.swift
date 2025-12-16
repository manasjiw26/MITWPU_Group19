//
//  MoodCheckInCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class MoodCheckInCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var moodImage: UIImageView!
    @IBOutlet weak var moodLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCells(mood: MoodCheckIn) {
        label.text = mood.label
        moodImage.image = UIImage(named: mood.imageName)
        moodLabel.text = mood.moodLabel
    }

}
