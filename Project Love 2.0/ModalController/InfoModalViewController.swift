//
//  InfoModalViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 26/03/26.
//

import UIKit

protocol InfoModalDelegate: AnyObject {
    func didTapLetsDoThis(for activity: Activity)
}

class InfoModalViewController: UIViewController {

    var activity: Activity?
    weak var delegate: InfoModalDelegate?
    
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var letsDoThisButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.bringSubviewToFront(modalView)
        
        // Configure close button
        closeButton.configuration = .glass()
        closeButton.setImage(
            UIImage(
                systemName: "xmark",
                withConfiguration: UIImage.SymbolConfiguration(weight: .medium)
            ),
            for: .normal
        )

        // Configure action button
        letsDoThisButton.configuration = .glass()
        letsDoThisButton.setTitle("Let's do this", for: .normal)

        // Populate data
        if let activity = activity {
            mainImage.image = UIImage(named: activity.image)
            // Simplify title: strip everything after colon (e.g., "Love Note: Quick Send" → "Love Note")
            let fullName = activity.name
            if let colonRange = fullName.range(of: ":") {
                titleLabel.text = String(fullName[fullName.startIndex..<colonRange.lowerBound]).trimmingCharacters(in: .whitespaces)
            } else {
                titleLabel.text = fullName
            }
            descriptionLabel.text = activity.modalDescription ?? activity.description
            locationLabel.text = activity.location ?? "Explore"
        }

        // Dim background
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        // Modal container styling
        modalView.backgroundColor = .white
        modalView.layer.cornerRadius = 40
        modalView.layer.masksToBounds = true

        view.addSubview(modalView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .clear
        modalView.transform = CGAffineTransform(translationX: 0, y: 400)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            self.modalView.transform = .identity
        })
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.modalView.transform = CGAffineTransform(translationX: 0, y: 400)
        }) { _ in
            self.dismiss(animated: true)
        }
    }

    @IBAction func letsDoThisButtonTapped(_ sender: Any) {
        let activityToRemove = activity
        UIView.animate(withDuration: 0.25, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.modalView.transform = CGAffineTransform(translationX: 0, y: 400)
        }) { _ in
            self.dismiss(animated: true) {
                if let activity = activityToRemove {
                    self.delegate?.didTapLetsDoThis(for: activity)
                }
            }
        }
    }
}
