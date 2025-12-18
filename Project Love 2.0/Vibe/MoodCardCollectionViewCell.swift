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
    @IBOutlet weak var Hismood: UIImageView!
    @IBOutlet weak var Hermood: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 28
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
        
    }
    func configureCell(){
        let hisMood = dataStore.getHisMood()
        let herMood = dataStore.getHerMood()
        Hismood.image = UIImage(named: hisMood?.imageName ?? "")
        Hermood.image = UIImage(named: herMood?.imageName ?? "")
        moodLabel.text = "How are you feeling today?"
        moodCardDescriptionLabel.text = "Set your mood to get activities made just for you!"
    }

}
