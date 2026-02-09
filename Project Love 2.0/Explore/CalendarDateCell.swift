import UIKit

class CalendarDateCell: UICollectionViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var selectionLayer: UIView!
    @IBOutlet weak var dotView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectionLayer.layer.cornerRadius = selectionLayer.frame.height / 2
        selectionLayer.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectionLayer.backgroundColor = .clear
        dotView?.isHidden = true
        dayLabel.textColor = .black
        contentView.alpha = 1.0
        isUserInteractionEnabled = true
    }
    
    func configure(day: String, isSelected: Bool, hasPlan: Bool, isFuture: Bool, isToday: Bool) {

        dayLabel.text = day
        selectionLayer.backgroundColor = .clear
        dotView?.isHidden = true

        guard !day.isEmpty else { return }

        dayLabel.textColor = .black

        if isSelected {
            selectionLayer.backgroundColor = UIColor(named: "PurpleColor")
            dayLabel.textColor = .white
            return
        }

        if isToday {
            selectionLayer.backgroundColor =
                UIColor(named: "PurpleColor")?.withAlphaComponent(0.2)
            dayLabel.textColor = UIColor(named: "PurpleColor")
        }

        if hasPlan {
            dotView?.isHidden = false
            dotView?.backgroundColor = UIColor(named: "PurpleColor")
        }
    }
}
