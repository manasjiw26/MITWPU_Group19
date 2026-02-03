import UIKit

class RefreshActivityCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var refreshbutton: UIButton!
    
    var onRefreshTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        setupButton()
        setupConstraints()
    }
    
    private func setupButton() {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        let image = UIImage(systemName: "arrow.clockwise", withConfiguration: symbolConfig)

        var config = UIButton.Configuration.glass()
        config.image = image
        config.baseBackgroundColor = .clear           
        config.background.cornerRadius = 18
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 6, leading: 6, bottom: 6, trailing: 6
        )

        refreshbutton.configuration = config
        refreshbutton.tintColor = .label
    }
    
    private func setupConstraints() {
        refreshbutton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            refreshbutton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            refreshbutton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            refreshbutton.widthAnchor.constraint(equalToConstant: 36),
            refreshbutton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    @IBAction func refreshAction(_ sender: UIButton) {
        onRefreshTapped?()
    }
}

