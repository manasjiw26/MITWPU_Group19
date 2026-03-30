//
//  RelationshipVibeDisplayCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 30/03/26.
//

import UIKit

class RelationshipVibeDisplayCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel?
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var vibeImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var dotsTopConstraint: NSLayoutConstraint?
    @IBOutlet weak var buttonTopConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var dot1: UIView?
    @IBOutlet weak var dot2: UIView?
    @IBOutlet weak var dot3: UIView?
    @IBOutlet weak var dot4: UIView?

    weak var delegate: DailyCheckInCellDelegate?

    private var isCompletedState = false

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 16
        layer.masksToBounds = false
        backgroundColor = .clear
        
        // Add button target programmatically
        actionButton.addTarget(self, action: #selector(getExerciseButton(_:)), for: .touchUpInside)
        
        // Make dots round
        [dot1, dot2, dot3, dot4].compactMap { $0 }.forEach {
            $0.layer.cornerRadius = ($0.frame.height > 0 ? $0.frame.height : 12) / 2
            $0.layer.masksToBounds = true
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
        isCompletedState = false
    }

    // MARK: - Default (Not Completed)
    func configureCells() {
        isCompletedState = false
        actionButton.isEnabled = true
        titleLabel.text = "Quick Vibe check"
        subtitleLabel?.text = "Questions to plan today's activities for you two."
        vibeImageView.image = UIImage(named: "DailyCheckIn")

        actionButton.configuration = .filled()
        actionButton.configuration?.title = "Let's do this"
        actionButton.configuration?.baseForegroundColor = .label
        actionButton.configuration?.baseBackgroundColor = .white
        actionButton.configuration?.buttonSize = .medium
        actionButton.configuration?.cornerStyle = .capsule
        
        // Hide progress elements and collapse spacing when not completed
        progressView?.isHidden = true
        dot1?.superview?.isHidden = true // hide the stackview containing the dots
        dotsTopConstraint?.constant = 0
        buttonTopConstraint?.constant = 8
    }

    // MARK: - Completed State
    func configureAsCompleted(vibeTitle: VibeTitle, totalCount: Int, remainingCount: Int, hasOpenedModal: Bool) {
        isCompletedState = true
        titleLabel.text = vibeTitle.displayTitle
        subtitleLabel?.text = vibeTitle.description
        vibeImageView.image = UIImage(named: vibeTitle.imageName)

        actionButton.configuration = .filled()
        actionButton.configuration?.baseForegroundColor = .label
        actionButton.configuration?.baseBackgroundColor = .white
        actionButton.configuration?.buttonSize = .large
        actionButton.configuration?.cornerStyle = .capsule

        if !hasOpenedModal {
            actionButton.configuration?.title = "Let's begin"
            actionButton.isEnabled = true
        } else if remainingCount > 0 {
            actionButton.configuration?.title = "Continue"
            actionButton.isEnabled = true
        } else {
            actionButton.configuration?.title = "Done ✅"
            actionButton.isEnabled = false
        }
        
        // Show and setup progress elements with spacing
        progressView?.isHidden = false
        dot1?.superview?.isHidden = false
        dotsTopConstraint?.constant = 22
        buttonTopConstraint?.constant = 20
        
        // Progress logic: 4 dots means 3 intervals.
        let completed = totalCount - remainingCount
        let progress = min(Float(completed) / 3.0, 1.0)
        progressView?.progress = progress
        
        // Map progress to the 4 dots
        let dots = [dot1, dot2, dot3, dot4]
        for (index, dot) in dots.enumerated() {
            let threshold = Float(index) / 3.0 // 0.0, 0.33, 0.66, 1.0
            
            if progress >= threshold || (index == 0 && completed >= 0) {
                // Reached or passed this dot
                dot?.backgroundColor = UIColor(red: 128/255, green: 99/255, blue: 181/255, alpha: 1.0)
            } else {
                dot?.backgroundColor = .white
            }
        }
    }

    // MARK: - Button Action
    @objc func getExerciseButton(_ sender: UIButton) {
        if isCompletedState {
            delegate?.didTapShowSuggestedActivities()
        } else {
            delegate?.didTapGetExercise()
        }
    }
}
