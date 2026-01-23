import UIKit

class QnATableViewCell: UITableViewCell {

    @IBOutlet weak var radioButton: UIButton!
    @IBOutlet weak var optionTextField: UITextField!

    var radioTapAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        optionTextField.borderStyle = .none
    }

    @IBAction func radioButtonTapped(_ sender: UIButton) {
        radioTapAction?()
    }

    func configure(option: QnAOption) {
        optionTextField.text = option.text

        let imageName = option.isSelected
            ? "largecircle.fill.circle"
            : "circle"

        radioButton.setImage(
            UIImage(systemName: imageName),
            for: .normal
        )
    }
}

