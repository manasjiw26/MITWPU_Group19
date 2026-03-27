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

    private let wScale = UIScreen.main.bounds.width / 393.0

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    func configureTitle(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle

        if title == "Nudges" {
            titleLabel.font = UIFont.systemFont(ofSize: 24 * wScale, weight: .bold)
        } else {
            titleLabel.font = UIFont.systemFont(ofSize: 20 * wScale, weight: .semibold)
        }
        subtitleLabel.font = UIFont.systemFont(ofSize: 15 * wScale)
    }

}
