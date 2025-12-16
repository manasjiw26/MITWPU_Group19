//
//  MoodCheckInCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit
protocol MoodCheckInCellDelegate: AnyObject {
    func didTapMood(in cell: MoodCheckInCollectionViewCell)
}
class MoodCheckInCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var moodImage: UIImageView!
    @IBOutlet weak var moodLabel: UILabel!
    @IBOutlet weak var circleView: UIView!
    
    weak var delegate: MoodCheckInCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.addSubview(circleView)
        contentView.sendSubviewToBack(circleView)
        // Enable tap on image
        moodImage.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(moodTapped))
        moodImage.addGestureRecognizer(tap)
        // Card appearance
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = false
        self.backgroundColor = .white
        
        // Shadow (optional)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.08
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 6
        
        
        circleView.layer.cornerRadius = 25  // half of 50 width
        circleView.layer.masksToBounds = false
        circleView.backgroundColor = .appBackground
        circleView.layer.borderWidth = 3.5
        circleView.layer.borderColor = UIColor.white.cgColor
        
        circleView.layer.shadowColor = UIColor.black.cgColor
        circleView.layer.shadowOpacity = 0.15
        circleView.layer.shadowRadius = 4
        circleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        
    }
    @objc private func moodTapped() {
        delegate?.didTapMood(in: self)
    }
    
    func configureCells(mood: MoodCheckIn) {
        label.text = mood.label
        moodImage.image = UIImage(named: mood.imageName)
        moodLabel.text = mood.moodLabel
    }
    
    func updateMood(imageName: String,moodText: String) {
        moodImage.image = UIImage(named: imageName)
        moodLabel.text = moodText
    }
    
}
