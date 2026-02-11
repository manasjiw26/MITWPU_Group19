//
//  HoveringOngoingActivityCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 11/02/26.
//

import UIKit

class HoveringOngoingActivityCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var bacgroundActivityView: UIView!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var ActivityImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var viewAll: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        view.applyLiquidGlassEffect()
        bacgroundActivityView.applyLiquidGlassEffect()
        view.layer.cornerRadius = 20
        bacgroundActivityView.layer.cornerRadius = 20
        view.clipsToBounds = true
        bacgroundActivityView.clipsToBounds = true
        
    }
    func configureCell(activity : Activity,Activitycount : Int){
        if Activitycount < 2 {
            bacgroundActivityView.isHidden = true
            viewAll.isHidden = true
        }
        else{
            bacgroundActivityView.isHidden = false
            viewAll.isHidden = false
        }
        ActivityImage.image = UIImage(named: activity.image)
        title.text = activity.name
        
    }
    
    
}
