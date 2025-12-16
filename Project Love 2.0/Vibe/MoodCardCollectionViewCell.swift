//
//  MoodCardCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class MoodCardCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var moodImageView: UIImageView!
    @IBOutlet weak var moodLabel: UILabel!
    @IBOutlet weak var moodCardDescriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 28
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
        
    }
    func configureCell(){
        moodImageView.image = UIImage(named: "MoodImage")
        moodLabel.text = "How are you feeling today?"
        moodCardDescriptionLabel.text = "Set your mood to get activities made just for you!"
    }

}
