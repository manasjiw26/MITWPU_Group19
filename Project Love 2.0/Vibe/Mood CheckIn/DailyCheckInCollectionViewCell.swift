import UIKit

protocol DailyCheckInCellDelegate: AnyObject {
    func didTapGetExercise()
    func didTapShowSuggestedActivities()
}

class DailyCheckInCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var checkInImageView: UIImageView!
    @IBOutlet weak var checkInTitleLabel: UILabel!
    @IBOutlet weak var checkInSubTitleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!

    weak var delegate: DailyCheckInCellDelegate?

    /// Tracks whether the cell is in completed (vibe title) state
    private var isCompletedState = false

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 16
        layer.masksToBounds = false
        backgroundColor = .clear
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
        isCompletedState = false
    }

    // MARK: - Default (Not Completed)
    func configureCells() {
        isCompletedState = false
        checkInTitleLabel.text = "Quick Vibe check"
        checkInSubTitleLabel.text = "Questions to plan today's activities for you two."
        checkInImageView.image = UIImage(named: "DailyCheckIn")

        actionButton.configuration = .filled()
        actionButton.configuration?.title = "Let's do this"
        actionButton.configuration?.baseForegroundColor = .label
        actionButton.configuration?.baseBackgroundColor = .white
        actionButton.configuration?.buttonSize = .medium
        actionButton.configuration?.cornerStyle = .capsule
    }

    // MARK: - Completed State (Shows Vibe Title)
    /// `remainingCount` drives button text: >0 → "Continue", 0 → "Done", first time → "Tap"
    func configureAsCompleted(vibeTitle: VibeTitle, remainingCount: Int, hasOpenedModal: Bool) {
        isCompletedState = true
        checkInTitleLabel.text = vibeTitle.displayTitle
        checkInSubTitleLabel.text = vibeTitle.description
        checkInImageView.image = UIImage(named: vibeTitle.imageName)

        actionButton.configuration = .filled()
        actionButton.configuration?.baseForegroundColor = .label
        actionButton.configuration?.baseBackgroundColor = .white
        actionButton.configuration?.buttonSize = .large

        if !hasOpenedModal {
            // Haven't opened the modal yet — show "Tap"
            actionButton.configuration?.title = "Tap"
        } else if remainingCount > 0 {
            // Activities still remaining — show "Continue"
            actionButton.configuration?.title = "Continue"
        } else {
            // All activities done — show "Done"
            actionButton.configuration?.title = "Done ✅"
            actionButton.isEnabled = false
        }
    }

    // MARK: - Button Action
    @IBAction func getExerciseButton(_ sender: UIButton) {
        if isCompletedState {
            delegate?.didTapShowSuggestedActivities()
        } else {
            delegate?.didTapGetExercise()
        }
    }
}
