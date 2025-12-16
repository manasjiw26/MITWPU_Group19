//
//  TitleCollectionResuableView.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class TitleCollectionResuableView: UICollectionReusableView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configureTitle(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
