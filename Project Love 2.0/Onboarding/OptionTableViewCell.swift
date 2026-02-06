import UIKit

class OptionTableViewCell: UITableViewCell {

    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var radioImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        contentView.backgroundColor = .white
        backgroundColor = .clear
    }

    // UPDATED: Added isMultiSelect parameter
    func configure(option: String, isSelected: Bool, isMultiSelect: Bool) {
        optionLabel.text = option

        if isSelected {
            // If it's the last question (multi-select), show a checkmark.
            // Otherwise, show the filled radio circle.
            let imageName = isMultiSelect ? "checkmark.circle.fill" : "largecircle.fill.circle"
            radioImageView.image = UIImage(systemName: imageName)
//            radioImageView.tintColor = .systemBlue
//            Optional: Different color for selection
        } else {
            // Default empty circle for unselected state
            radioImageView.image = UIImage(systemName: "circle")
//            radioImageView.tintColor = .systemGray4
        }
    }
}
