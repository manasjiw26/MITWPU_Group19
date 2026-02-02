import UIKit

class optionsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var optionImageView: UIImageView!
    @IBOutlet weak var optionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Setup the base look
        self.contentView.layer.cornerRadius = 20
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.systemGray5.cgColor
        self.contentView.backgroundColor = .white
        
        // IMPORTANT: Disable the default system highlight (which is often red/gray)
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = .clear
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                // Apply the Figma Purple
                let figmaPurple = UIColor(red: 0.61, green: 0.45, blue: 0.89, alpha: 1.0) // Your purple
                self.contentView.layer.borderColor = figmaPurple.cgColor
                self.contentView.layer.borderWidth = 2.0
                // Light purple tint for the background
                self.contentView.backgroundColor = figmaPurple.withAlphaComponent(0.1)
            } else {
                // Revert to unselected state
                self.contentView.layer.borderColor = UIColor.systemGray5.cgColor
                self.contentView.layer.borderWidth = 1.0
                self.contentView.backgroundColor = .white
            }
        }
    }

    func configure(with optionText: String) {
        optionLabel.text = optionText
        optionImageView.image = UIImage(named: (optionText + "_option"))
    }
    
    
}
