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
            btn.layer.borderWidth = 3
            btn.backgroundColor = .white
            
            
            if let widthConstraint = btn.constraints.first(where: { $0.firstAttribute == .height }) {
                widthConstraint.constant = btn.bounds.width
            } else {
                btn.heightAnchor.constraint(equalToConstant: btn.bounds.width).isActive = true
            }
        }
    }

    func configure(bond: BuildYourBondpage) {

        heading.text = bond.Name
        subHeading.text = bond.SubHeading

        // Update progress text
        updateProgressLabel(bond: bond)

        for i in 0..<circleButton.count {

        // Step titles (Identify, Empathize, etc.)
        circlesubtitleLabel[i].text = bond.step[i]

        // Render unlocked / locked state
        renderCircle(at: i, bond: bond)
        }
    }

    private func renderCircle(
        at index: Int,
        bond: BuildYourBondpage
    ) {
        let button = circleButton[index]

        // checking if current step is unlocked
        let isUnlocked: Bool
        if index == 0 {
            isUnlocked = true
        } else {
            isUnlocked = bond.activity[index - 1].status == .completed
        }

        // Circle styling (unlock-based)
        button.layer.borderColor =
            isUnlocked ? UIColor.systemBlue.cgColor : UIColor.lightGray.cgColor

        button.setTitleColor(
            isUnlocked ? .systemBlue : .lightGray,
            for: .normal
        )

        //  Line styling (completion-based)
        // Line before this circle
        if index > 0 {
            let line = lineView[index - 1]
            let previousCompleted =
                bond.activity[index - 1].status == .completed

            line.backgroundColor =
                previousCompleted ? .systemBlue : .lightGray
        }
    }


    
    
    // to update progressLabel
    
    private func updateProgressLabel(bond: BuildYourBondpage) {

        var completedCount = 0

        // Count completed activities
        for activity in bond.activity {
            if activity.status == .completed {
                completedCount += 1
            }
        }

        // If all activities are completed
        if completedCount == bond.activity.count {
            progressLabel.text = "You've completed all steps! "
            return
        }

        // Current step user is on
        let stepIndex = completedCount
        let stepNumber = stepIndex + 1
        let stepName = bond.activity[stepIndex].name

        progressLabel.text =
        "You are currently on Step \(stepNumber): \(stepName)."
    }

}

