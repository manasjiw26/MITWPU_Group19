//
//  BUBSectionOneCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit

class BUBSection1CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var subHeading: UILabel!
    @IBOutlet var circleButton: [UIButton]!
    @IBOutlet var lineView: [UIView]!
    @IBOutlet var circlesubtitleLabel: [UILabel]!
    @IBOutlet var progressLabel: UILabel!
    
//    private var sectionView: BUBSection1?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .white
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for btn in circleButton {
            btn.layer.cornerRadius = btn.bounds.width / 2
            btn.layer.masksToBounds = true
            btn.layer.borderColor = UIColor.lightGray.cgColor
            btn.layer.borderWidth = 3
            btn.backgroundColor = .white

            // Make height = width
            if let widthConstraint = btn.constraints.first(where: { $0.firstAttribute == .height }) {
                widthConstraint.constant = btn.bounds.width
            } else {
                btn.heightAnchor.constraint(equalToConstant: btn.bounds.width).isActive = true
            }
        }
    }
    func configure(bond : BuildYourBondpage){
        if let data: BuildYourBondpage = dataStore.getBuildYourBondPages(name : bond.Name){
            heading.text = data.Name
            subHeading.text = data.SubHeading
            progressLabel.text = data.stepLabel
            loadSectionView(bond : data)
        }
        
    }
    func loadSectionView(bond : BuildYourBondpage) {
//        for i in 0..<circleButton.count{
//            print(i)
//            print(circleButton[i].frame.size.width)
////            circleButton[i].frame.size.height = circleButton[i].frame.width
////            circleButton[i].frame.size.height = 50
//            circleButton[i].heightAnchor.constraint(equalToConstant: circleButton[i].frame.width).isActive = true
//            print(circleButton[i].frame.height)
//            circleButton[i].layer.cornerRadius = circleButton[i].frame.width / 2
//            
//            circleButton[i].translatesAutoresizingMaskIntoConstraints = false
//            
//            circleButton[i].layer.masksToBounds = true
//            circleButton[i].backgroundColor = .white
//            circleButton[i].layer.borderColor = UIColor.lightGray.cgColor
//            circleButton[i].layer.borderWidth = 3
//        }
        for i in 0..<lineView.count{
            lineView[i].backgroundColor = .lightGray
            lineView[i].translatesAutoresizingMaskIntoConstraints = false
        }
        for i in 0..<circlesubtitleLabel.count{
            circlesubtitleLabel[i].text = bond.step[i]
            circlesubtitleLabel[i].setContentCompressionResistancePriority(.required, for: .horizontal)
            
        }
    }
}
