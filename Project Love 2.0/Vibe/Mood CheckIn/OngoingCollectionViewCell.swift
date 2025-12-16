//
//  OngoingCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

class OngoingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var OngoingTitle: UILabel!
    @IBOutlet weak var OngoingSubTitle: UILabel!
    @IBOutlet weak var OngoingImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = false
        self.backgroundColor = .white
    }
    func configureCells(){
            OngoingTitle.text = "No Ongoing Activity"
            OngoingSubTitle.text = "Take a moment to check in or try a new activity that fits your vibe today."
            OngoingImage.image = UIImage(named: "No Ongoing Activity")
        }
}
