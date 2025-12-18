import UIKit

protocol DailyCheckInCellDelegate: AnyObject {
    func didTapGetExercise()
}

class DailyCheckInCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var checkInImageView: UIImageView!
    @IBOutlet weak var checkInTitleLabel: UILabel!
    @IBOutlet weak var checkInSubTitleLabel: UILabel!

    weak var delegate: DailyCheckInCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 16
        layer.masksToBounds = false
        backgroundColor = UIColor(
            red: 168/255,
            green: 171/255,
            blue: 222/255,
            alpha: 0.6
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }

    // MARK: - Default (Not Completed)
    func configureCells() {
        checkInTitleLabel.text = "Daily check-in"
        checkInSubTitleLabel.text = "Get personalised exercises based on your relationship"
        checkInImageView.image = UIImage(named: "DailyCheckIn")
    }

    // MARK: - Completed State (Optional)
    func configureAsCompleted(title: String, subtitle: String) {
        checkInTitleLabel.text = title
        checkInSubTitleLabel.text = subtitle
    }

    // MARK: - Button Action
    @IBAction func getExerciseButton(_ sender: UIButton) {
        delegate?.didTapGetExercise()
    }
}
