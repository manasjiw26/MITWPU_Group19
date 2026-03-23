//
//  RewardNotificationViewController.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 23/03/26.
//

import UIKit

class RewardNotificationViewController: UIViewController {

    @IBOutlet weak var rewardLabel: UILabel!
    @IBOutlet weak var rewardNudgeimage: UIImageView!
    @IBOutlet weak var rewarddescription: UILabel!
    
    // Storyboard residual connections to prevent crashes
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var notificationTitle: String?
    var notificationMessage: String?
    var notificationImage: UIImage?
    var notificationEmoji: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        popupView.layer.cornerRadius = 28
        popupView.layer.masksToBounds = true
        popupView.backgroundColor = .white
        
        //Shadow styling
        popupView.layer.shadowColor = UIColor.black.cgColor
        popupView.layer.shadowOpacity = 0.15
        popupView.layer.shadowOffset = CGSize(width: 0, height: 8)
        popupView.layer.shadowRadius = 20
        popupView.layer.masksToBounds = false
        
        dismissButton.configuration = .glass()
        dismissButton.setImage(
            UIImage(
                systemName: "xmark",
                withConfiguration: UIImage.SymbolConfiguration(weight: .medium)
            ),
            for: .normal
        )
        dismissButton.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        dismissButton.layer.cornerRadius = 16
        if let titleText = notificationTitle {
            rewardLabel.text = titleText
        }
        
        if let messageText = notificationMessage {
            rewarddescription.text = messageText
        }
        
        if let emoji = notificationEmoji {
            // Hide the image view and show the emoji as a large label
            rewardNudgeimage.isHidden = true
            let emojiLabel = UILabel()
            emojiLabel.text = emoji
            emojiLabel.font = UIFont.systemFont(ofSize: 120)
            emojiLabel.textAlignment = .center
            emojiLabel.translatesAutoresizingMaskIntoConstraints = false
            popupView.addSubview(emojiLabel)
            NSLayoutConstraint.activate([
                emojiLabel.centerXAnchor.constraint(equalTo: rewardNudgeimage.centerXAnchor),
                emojiLabel.centerYAnchor.constraint(equalTo: rewardNudgeimage.centerYAnchor),
                emojiLabel.widthAnchor.constraint(equalTo: rewardNudgeimage.widthAnchor),
                emojiLabel.heightAnchor.constraint(equalTo: rewardNudgeimage.heightAnchor)
            ])
        } else if let image = notificationImage {
            rewardNudgeimage.image = image
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showConfetti()
    }
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func showConfetti() {
        let confettiLayer = CAEmitterLayer()
        
        confettiLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -50)
        confettiLayer.emitterShape = .line
        confettiLayer.emitterSize = CGSize(width: view.bounds.size.width, height: 1)
        
        // Vibrant confetti colors
        let colors: [UIColor] = [
            UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0),    // Gold
            UIColor(red: 1.0, green: 0.4, blue: 0.6, alpha: 1.0),    // Hot Pink
            UIColor(red: 0.5, green: 0.2, blue: 0.9, alpha: 1.0),    // Purple
            UIColor(red: 0.2, green: 0.9, blue: 0.5, alpha: 1.0),    // Green
            UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0),    // Orange
            UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0),    // Blue
            UIColor(red: 1.0, green: 0.2, blue: 0.3, alpha: 1.0),    // Red
            UIColor(red: 0.9, green: 0.9, blue: 0.2, alpha: 1.0)     // Yellow
        ]
        
        var cells: [CAEmitterCell] = []
        
        for color in colors {
            for _ in 0..<1 {
                let cell = CAEmitterCell()

                cell.birthRate = 3
                cell.lifetime = 6.0
                cell.lifetimeRange = 2

                cell.velocity = CGFloat.random(in: 150...250)
                cell.velocityRange = 60
                cell.emissionLongitude = .pi
                cell.emissionRange = .pi / 4

                cell.spin = CGFloat.random(in: 1...3)
                cell.spinRange = 2

                cell.scale = CGFloat.random(in: 0.2...0.4)
                cell.scaleRange = 0.1
                cell.scaleSpeed = -0.05

                cell.yAcceleration = 150
                cell.xAcceleration = CGFloat.random(in: -20...20)

                cell.alphaSpeed = -0.15
                cell.color = color.cgColor

                let shapes = ["circle", "square", "triangle"]
                let randomShape = shapes.randomElement() ?? "circle"
                cell.contents = confettiImage(shape: randomShape, color: color)?.cgImage

                cells.append(cell)
            }
        }
        confettiLayer.emitterCells = cells
        view.layer.addSublayer(confettiLayer)
        
        // Stop emitting new particles after 2 seconds, but let existing ones finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            confettiLayer.birthRate = 0
        }
        
        // Remove layer completely after animation finishes
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
            confettiLayer.removeFromSuperlayer()
        }
    }
    
    func confettiImage(shape: String, color: UIColor) -> UIImage? {
        let size = CGSize(width: 10, height: 10)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            color.setFill()
            
            switch shape {
            case "square":
                let rect = CGRect(x: 1, y: 1, width: 8, height: 8)
                context.cgContext.fill(rect)
                
            case "triangle":
                let path = UIBezierPath()
                path.move(to: CGPoint(x: size.width/2, y: 1))
                path.addLine(to: CGPoint(x: 1, y: size.height - 1))
                path.addLine(to: CGPoint(x: size.width - 1, y: size.height - 1))
                path.close()
                path.fill()
                
            case "circle":
                let rect = CGRect(x: 1, y: 1, width: 8, height: 8)
                context.cgContext.fillEllipse(in: rect)
                
            default:
                break
            }
        }
    }
    


}
