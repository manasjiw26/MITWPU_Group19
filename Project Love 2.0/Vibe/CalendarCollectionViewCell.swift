//
//  CalendarCollectionViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.layer.cornerRadius = 19
        contentView.layer.masksToBounds = true
        
    }
    func configureCell(day : DayInfo){
        dateLabel.text = "\(day.date)"
        dayLabel.text = "\(day.day)"
        contentView.backgroundColor = day.color
    }
    func configureTodayCell(day : DayInfo){
        dateLabel.text = "\(day.date)"
        dayLabel.text = "Today"
        contentView.backgroundColor = day.color
    }

}
