//
//  BUBSection4CollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 12/12/25.
//

import UIKit

class BUBSection4CollectionViewCell: UICollectionViewCell {
//    @IBOutlet var dottedViews : [UIView]!
//    @IBOutlet var dottedStackView : UIStackView!
    @IBOutlet var lockView : UIView!
    @IBOutlet var ActivityTitleLabel : UILabel!
    @IBOutlet var ActivitydescriptionLabel : UILabel!
    @IBOutlet var ActivityimageView : UIImageView!
    @IBOutlet var ActivityView : UIView!
    @IBOutlet var separatorImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        //dottedline()
    }
//    func dottedline(){
//        for i in 0..<dottedViews.count{
//            dottedViews[i].layer.cornerRadius = 1
//            dottedViews[i].layer.masksToBounds = true
//            dottedViews[i].backgroundColor = .systemGray6
//        }
//    }
    func configureCells(activity: Activity, index: Int, total: Int) {

        ActivityTitleLabel.text = "Level \(index + 1): \(activity.name)"
        ActivitydescriptionLabel.text = activity.description
        ActivityimageView.image = UIImage(named: activity.image)

        // Separator (UI responsibility)
        separatorImageView.image = UIImage(named: "SeparatorImage")
        separatorImageView.isHidden = index == total - 1  

        // Default states
        lockView.isHidden = true
        ActivityimageView.alpha = 1.0
        ActivityTitleLabel.alpha = 1.0
        ActivitydescriptionLabel.alpha = 1.0

        ActivityView.layer.cornerRadius = 10
        ActivityView.backgroundColor = .white

        // 🔒 LOCK LOGIC
        if index != 0 {
            lockView.isHidden = false
            ActivityimageView.alpha = 0.5
            ActivityTitleLabel.alpha = 0.5
            ActivitydescriptionLabel.alpha = 0.5
            ActivityView.backgroundColor = .systemGray4
        }
    }
}
