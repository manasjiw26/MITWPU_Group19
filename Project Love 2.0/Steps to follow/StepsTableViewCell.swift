//
//  StepsTableViewCell.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 12/12/25.
//

import UIKit

struct StepCardModel {
    let stepNumber: Int
    let title: String
    let description: String
    let leftImageName: String
    let rightImageName: String
    let waveVariant: Int  // 0, 1, 2, 3 — different wave shape per card
}

class CardWaveBackgroundView: UIView {
    
    /// swipeProgress: 0.0 = swiped away, 1.0 = fully active/centered on this card
    /// The wave animates smoothly based on this — moving forward when going to next step,
    /// and backward when going to previous step
    var swipeProgress: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Which wave shape variant to draw (0–3), each card gets a unique shape
    /// Card 0 & 2: Normal wave curve
    /// Card 1 & 3: Inverted wave curve (mirrored)
    var waveVariant: Int = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let width = rect.width
        let height = rect.height
        
        // Fill base white for the entire card
        UIColor.white.setFill()
        context.fill(rect)
        
        // ─── WAVE SHAPE LOGIC ───
        // Card 0 & 2 (even): Normal wave — curve goes high-left, dips right
        // Card 1 & 3 (odd):  Inverted wave — curve goes high-right, dips left
        let isInverted = (waveVariant % 2 == 1)
        
        // Wave vertical position — center of the card, slightly above middle
        let waveBaseY = height * 0.42
        
        // Amplitude of the wave curve
        let amplitude: CGFloat = height * 0.10
        
        // Horizontal phase shift driven by swipe — creates the "wave moving" effect
        let phaseShift = (1.0 - swipeProgress) * width * 0.35
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // ─── SECONDARY (BACK) WAVE — translucent, alternating curve direction ───
        context.saveGState()
        
        let backWaveOffset: CGFloat = height * 0.04
        let backAmplitude = amplitude * 1.15
        let backPhaseShift = phaseShift * 1.2
        
        // Back wave alternates opposite to main wave for visual variety
        let backInverted = !isInverted
        
        let backLeftY: CGFloat
        let backRightY: CGFloat
        let backCP1: CGPoint
        let backCP2: CGPoint
        
        if backInverted {
            // Inverted back wave: high on right, dips left
            backLeftY = waveBaseY + backWaveOffset - backAmplitude * 0.3
            backRightY = waveBaseY + backWaveOffset + backAmplitude * 0.3
            backCP1 = CGPoint(
                x: width * 0.35 - backPhaseShift * 0.6,
                y: waveBaseY + backWaveOffset + backAmplitude
            )
            backCP2 = CGPoint(
                x: width * 0.70 - backPhaseShift,
                y: waveBaseY + backWaveOffset - backAmplitude * 0.7
            )
        } else {
            // Normal back wave: high on left, dips right
            backLeftY = waveBaseY + backWaveOffset + backAmplitude * 0.3
            backRightY = waveBaseY + backWaveOffset - backAmplitude * 0.3
            backCP1 = CGPoint(
                x: width * 0.65 + backPhaseShift,
                y: waveBaseY + backWaveOffset + backAmplitude
            )
            backCP2 = CGPoint(
                x: width * 0.30 + backPhaseShift * 0.6,
                y: waveBaseY + backWaveOffset - backAmplitude * 0.7
            )
        }
        
        let back = UIBezierPath()
        back.move(to: CGPoint(x: 0, y: 0))
        back.addLine(to: CGPoint(x: width, y: 0))
        back.addLine(to: CGPoint(x: width, y: backRightY))
        back.addCurve(
            to: CGPoint(x: 0, y: backLeftY),
            controlPoint1: backCP1,
            controlPoint2: backCP2
        )
        back.close()
        back.addClip()
        
        let backColors = [
            UIColor(red: 170/255, green: 167/255, blue: 240/255, alpha: 0.35).cgColor,
            UIColor(red: 216/255, green: 214/255, blue: 255/255, alpha: 0.35).cgColor
        ] as CFArray
        let backGrad = CGGradient(colorsSpace: colorSpace, colors: backColors, locations: nil)!
        context.drawLinearGradient(backGrad, start: CGPoint(x: 0, y: 0), end: CGPoint(x: width, y: max(backLeftY, backRightY)), options: [])
        context.restoreGState()
        
        // ─── MAIN (FRONT) WAVE — opaque purple section ───
        context.saveGState()
        
        let mainLeftY: CGFloat
        let mainRightY: CGFloat
        let mainCP1: CGPoint
        let mainCP2: CGPoint
        
        if isInverted {
            // Inverted main wave: high on right side, dips on left
            mainLeftY = waveBaseY - amplitude * 0.25
            mainRightY = waveBaseY + amplitude * 0.25
            mainCP1 = CGPoint(
                x: width * 0.38 - phaseShift * 0.5,
                y: waveBaseY + amplitude
            )
            mainCP2 = CGPoint(
                x: width * 0.72 - phaseShift,
                y: waveBaseY - amplitude * 0.8
            )
        } else {
            // Normal main wave: high on left side, dips on right
            mainLeftY = waveBaseY + amplitude * 0.25
            mainRightY = waveBaseY - amplitude * 0.25
            mainCP1 = CGPoint(
                x: width * 0.62 + phaseShift,
                y: waveBaseY + amplitude
            )
            mainCP2 = CGPoint(
                x: width * 0.28 + phaseShift * 0.5,
                y: waveBaseY - amplitude * 0.8
            )
        }
        
        let main = UIBezierPath()
        main.move(to: CGPoint(x: 0, y: 0))
        main.addLine(to: CGPoint(x: width, y: 0))
        main.addLine(to: CGPoint(x: width, y: mainRightY))
        main.addCurve(
            to: CGPoint(x: 0, y: mainLeftY),
            controlPoint1: mainCP1,
            controlPoint2: mainCP2
        )
        main.close()
        main.addClip()
        
        let mainColors = [
            UIColor(red: 183/255, green: 180/255, blue: 240/255, alpha: 1.0).cgColor,
            UIColor(red: 199/255, green: 197/255, blue: 245/255, alpha: 1.0).cgColor
        ] as CFArray
        let mainGrad = CGGradient(colorsSpace: colorSpace, colors: mainColors, locations: nil)!
        context.drawLinearGradient(mainGrad, start: CGPoint(x: 0, y: 0), end: CGPoint(x: width, y: max(mainLeftY, mainRightY)), options: [])
        context.restoreGState()
    }
}

/// Holds all the control points for a wave variant
struct WaveControlPoints {
    let mainRightY: CGFloat
    let mainLeftY: CGFloat
    let mainCP1: CGPoint
    let mainCP2: CGPoint
    let backRightY: CGFloat
    let backLeftY: CGFloat
    let backCP1: CGPoint
    let backCP2: CGPoint
}

class StepCardCollectionViewCell: UICollectionViewCell {
    
    let containerView = CardWaveBackgroundView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let leftImageView = UIImageView()
    let rightImageView = UIImageView()
    
    var swipeProgress: CGFloat = 0.0 {
        didSet {
            containerView.swipeProgress = swipeProgress
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        
        // Add card container view — no border, clean rounded card
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 24
        containerView.layer.masksToBounds = true
        contentView.addSubview(containerView)
        
        // Add title label in top purple section
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 21, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        containerView.addSubview(titleLabel)
        
        // Add description label in bottom white section
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textColor = .black
        descriptionLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        containerView.addSubview(descriptionLabel)
        
        // Add left & right character image views inside containerView (clipped by rounded corners)
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        leftImageView.contentMode = .scaleAspectFill
        leftImageView.clipsToBounds = true
        containerView.addSubview(leftImageView)
        
        rightImageView.translatesAutoresizingMaskIntoConstraints = false
        rightImageView.contentMode = .scaleAspectFill
        rightImageView.clipsToBounds = true
        containerView.addSubview(rightImageView)
        
        // Apply card shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.15
        self.layer.shadowOffset = CGSize(width: 0, height: 8)
        self.layer.shadowRadius = 12
        self.layer.masksToBounds = false
        contentView.layer.masksToBounds = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Title constraints (pinned to top part — inside the purple wave area)
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.topAnchor, constant: 120),
            
            // Description constraints (centered in lower white section)
            descriptionLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 40),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // Left character: bottom-left, smaller size to avoid image cutting
            leftImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            leftImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            leftImageView.widthAnchor.constraint(equalToConstant: 75),
            leftImageView.heightAnchor.constraint(equalToConstant: 75),
            
            // Right character: bottom-right, smaller size to avoid image cutting
            rightImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            rightImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            rightImageView.widthAnchor.constraint(equalToConstant: 75),
            rightImageView.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    func configure(with model: StepCardModel) {
        titleLabel.text = "\(model.stepNumber). \(model.title):"
        descriptionLabel.text = model.description
        leftImageView.image = UIImage(named: model.leftImageName)
        rightImageView.image = UIImage(named: model.rightImageName)
        containerView.waveVariant = model.waveVariant
    }
}
