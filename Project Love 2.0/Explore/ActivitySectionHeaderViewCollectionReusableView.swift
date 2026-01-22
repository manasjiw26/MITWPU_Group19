//
//  ActivitySectionHeaderViewCollectionReusableView.swift
//  Project LOVE
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

protocol ActivityHeaderDelegate: AnyObject {
    func didChangeSegment(to index: Int)
}

class ActivitySectionHeaderViewCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    weak var delegate: ActivityHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    @IBAction func onSegmentChange(_ sender: UISegmentedControl) {
        
        delegate?.didChangeSegment(to: sender.selectedSegmentIndex)
        
    }
}
