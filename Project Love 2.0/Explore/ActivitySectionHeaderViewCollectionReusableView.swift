//
//  ActivitySectionHeaderViewCollectionReusableView.swift
//  Project LOVE
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class ActivitySectionHeaderViewCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var segmentedControl: UISegmentedControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    @IBAction func onSegmentChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            titleLabel.text = "Activities"
        case 1:
            titleLabel.text = "Ongoing"
        case 2:
            titleLabel.text = "Completed"
        case 3:
            titleLabel.text = "Custom"
            
        default:
            break
        }
    }
}
