//
//  RewardModalViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 07/01/26.
//

import UIKit

class RewardModalViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ringImageView: UIImageView!
    @IBOutlet var backgroundView: UIView!
    
    var rewardName: String?
    var onProgressUpdate: ((Int) -> Void)?

    private var step = 0

    private let ringImages = [
        "circle_0",
        "circle_25",
        "circle_50",
        "circle_75",
        "circle_100"
    ]
    var rewardEmoji: String = "🤗"
    var initialStep: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        
        step = initialStep
        titleLabel.text = rewardName
        emojiLabel.text = rewardEmoji
        ringImageView.image = UIImage(named: ringImages[step])


        containerView.layer.cornerRadius = 30
        containerView.layer.maskedCorners = [
               .layerMinXMinYCorner,
               .layerMaxXMinYCorner
           ]
    }
    private func updateRing() {
        UIView.transition(
            with: ringImageView,
            duration: 0.25,
            options: .transitionCrossDissolve
        ) {
            self.ringImageView.image =
                UIImage(named: self.ringImages[self.step])
        }

        // Emoji pop animation
        emojiLabel.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.6
        ) {
            self.emojiLabel.transform = .identity
        }
    }

    private func playStepHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func playSuccessHaptic() {
        UINotificationFeedbackGenerator()
            .notificationOccurred(.success)
    }

    private func dismissWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.dismiss(animated: true)
        }
    }

    @IBAction func handleEmojiTap(_ sender: UITapGestureRecognizer) {
        guard step < 4 else { return }

        step += 1
        updateRing()
        playStepHaptic()

        if step == 4 {
            playSuccessHaptic()
            dismissWithDelay()
        }
    }
}
