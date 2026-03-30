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
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // Remove existing views to clear storyboard constraints
        checkInTitleLabel.removeFromSuperview()
        checkInSubTitleLabel.removeFromSuperview()
        actionButton.removeFromSuperview()
        checkInImageView.removeFromSuperview()

        // Configure Labels
        checkInTitleLabel.numberOfLines = 0
        checkInTitleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        
        checkInSubTitleLabel.numberOfLines = 0
        checkInSubTitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        checkInSubTitleLabel.textColor = .darkGray

        checkInImageView.contentMode = .scaleAspectFit

        let leftStack = UIStackView(arrangedSubviews: [checkInTitleLabel, checkInSubTitleLabel, actionButton])
        leftStack.axis = .vertical
        leftStack.spacing = 8
        leftStack.alignment = .leading
        leftStack.distribution = .fill

        contentView.addSubview(leftStack)
        contentView.addSubview(checkInImageView)

        leftStack.translatesAutoresizingMaskIntoConstraints = false
        checkInImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            leftStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            leftStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            contentView.bottomAnchor.constraint(equalTo: leftStack.bottomAnchor, constant: 10),
            leftStack.trailingAnchor.constraint(equalTo: checkInImageView.leadingAnchor, constant: -12),

            // Button sizing
            actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            actionButton.heightAnchor.constraint(equalToConstant: 34),

            // Image
            checkInImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            checkInImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkInImageView.widthAnchor.constraint(equalToConstant: 90),
            checkInImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
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
            actionButton.configuration?.title = "Done"
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
