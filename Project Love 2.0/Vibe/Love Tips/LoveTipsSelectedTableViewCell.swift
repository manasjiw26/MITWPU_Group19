import UIKit

class LoveTipsSelectedTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var radioButtonSelected: UIButton!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .appBackground

        // Custom separator
        let separator = UIView()
        separator.backgroundColor = UIColor.separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)

        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])

        // Prevent default highlight effect
        radioButtonSelected.adjustsImageWhenHighlighted = false
    }

    // MARK: - Configure
    func configure(option: String, isSelected: Bool) {
        optionLabel.text = option

        let imageName = isSelected
            ? "largecircle.fill.circle"
            : "circle"

        radioButtonSelected.setImage(
            UIImage(systemName: imageName),
            for: .normal
        )
    }
}

