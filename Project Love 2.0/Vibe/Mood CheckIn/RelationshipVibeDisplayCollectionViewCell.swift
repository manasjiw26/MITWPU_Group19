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
    
    /// Left label — shows the current relationship vibe
    @IBOutlet weak var currentVibeLabel: UILabel?
    /// Right label — shows the resultant vibe after completing suggested activities
    @IBOutlet weak var resultVibeLabel: UILabel?
    
    @IBOutlet weak var dot1: UIView?
    @IBOutlet weak var dot2: UIView?
    @IBOutlet weak var dot3: UIView?
    @IBOutlet weak var dot4: UIView?
    @IBOutlet weak var dot5: UIView?

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
        [dot1, dot2, dot3, dot4, dot5].compactMap { $0 }.forEach {
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

    // MARK: - Vibe progression map
    static let vibeResultMap: [String: String] = [
        "The Always-Attached":    "The Unbreakable Bond",
        "The In-Sync Duo":        "The Effortless Flow",
        "The Power-Builders":     "The Power Couple",
        "The Mending Souls":      "The Healed & Stronger",
        "The Fresh-Start Pair":   "The Rekindled Flame",
        "The Deep-Dive Duo":      "The Soul-Connected",
        "The Independent Hearts": "The Perfect Balance",
        "The Reassurers":         "The Safe Haven",
        "The Routine-Steady":     "The Revived Rhythm",
        "The Life-Logistics Team":"The Thriving Partners",
        "The Wave-Riders":        "The Steady Tide",
        "The High-Emotion Duo":   "The Grounded Passion"
    ]

    // MARK: - Completed State
    func configureAsCompleted(vibeTitle: VibeTitle, totalCount: Int, remainingCount: Int, hasOpenedModal: Bool) {
        isCompletedState = true
        titleLabel.text = vibeTitle.displayTitle
        subtitleLabel?.text = vibeTitle.description
        vibeImageView.image = UIImage(named: vibeTitle.imageName)
        
        // Populate the current & resultant vibe labels
        let currentVibe = vibeTitle.displayTitle
        currentVibeLabel?.text = currentVibe
        resultVibeLabel?.text = Self.vibeResultMap[currentVibe] ?? currentVibe

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
            actionButton.configuration?.title = "Done"
            actionButton.isEnabled = false
        }
        
        // Show and setup progress elements with spacing
        progressView?.isHidden = false
        dot1?.superview?.isHidden = false
        dotsTopConstraint?.constant = 22
        buttonTopConstraint?.constant = 20
        
        // Progress logic: bar fills from 0 → 1 over totalCount completions.
        // Each of the 5 dots lights when the bar reaches its fractional position.
        let completed = totalCount - remainingCount
        let progress: Float = totalCount > 0 ? min(Float(completed) / Float(totalCount), 1.0) : 0.0
        progressView?.progress = progress
        
        // Dot[i] lights when progress >= i / totalCount  (evenly spaced across the bar)
        let purpleColor = UIColor(red: 128/255, green: 99/255, blue: 181/255, alpha: 1.0)
        let dots = [dot1, dot2, dot3, dot4, dot5]
        for (index, dot) in dots.enumerated() {
            let threshold: Float = totalCount > 0 ? Float(index) / Float(totalCount) : 0
            dot?.backgroundColor = progress >= threshold ? purpleColor : .white
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
