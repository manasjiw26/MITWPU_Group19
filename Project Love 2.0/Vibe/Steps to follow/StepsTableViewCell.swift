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
    
    /// Which wave shape variant to draw.
    /// Card 0 & 2: Normal wave curve
    /// Card 1 & 3: Inverted wave curve (mirrored)
    var waveVariant: Int = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Signed swipe offset used to move the wave forward/backward with the gesture.
    var swipeOffset: CGFloat = 0.0 {
        didSet {
            updateWaveMotionTarget(max(-1.0, min(1.0, swipeOffset)))
        }
    }

    private var waveMotion: CGFloat = 0.0
    private var waveMotionTarget: CGFloat = 0.0
    private var waveDisplayLink: CADisplayLink?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }

    deinit {
        waveDisplayLink?.invalidate()
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow == nil {
            waveDisplayLink?.invalidate()
            waveDisplayLink = nil
        }
    }

    private func updateWaveMotionTarget(_ target: CGFloat) {
        waveMotionTarget = target

        guard abs(waveMotionTarget - waveMotion) > 0.005 else {
            waveMotion = waveMotionTarget
            setNeedsDisplay()
            return
        }

        if waveDisplayLink == nil {
            let displayLink = CADisplayLink(target: self, selector: #selector(stepWaveMotion))
            displayLink.add(to: .main, forMode: .common)
            waveDisplayLink = displayLink
        }
    }

    @objc private func stepWaveMotion() {
        let remainingDistance = waveMotionTarget - waveMotion
        waveMotion += remainingDistance * 0.22

        if abs(remainingDistance) < 0.006 {
            waveMotion = waveMotionTarget
            waveDisplayLink?.invalidate()
            waveDisplayLink = nil
        }

        setNeedsDisplay()
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
        // Card 0 & 2 (even): Normal wave — left side high, right side dips down
        // Card 1 & 3 (odd):  Inverted wave — right side high, left side dips down
        let isInverted = (waveVariant % 2 == 1)
        
        // Wave vertical midpoint — sits at ~42% of card height
        let waveBaseY = height * 0.42
        
        // Deep, beautiful amplitude for a pronounced S-curve
        let amplitude: CGFloat = height * 0.13
        
        // Phase shift animates the wave in the direction of the swipe.
        let phaseShift = waveMotion * width * 0.30
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // ─── HELPER: build a wave bezier path from top-left corner ───
        // The wave edge goes from (0, leftY) to (width, rightY) with two control points.
        func wavePath(leftY: CGFloat, rightY: CGFloat, cp1: CGPoint, cp2: CGPoint) -> UIBezierPath {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: width, y: rightY))
            path.addCurve(to: CGPoint(x: 0, y: leftY), controlPoint1: cp1, controlPoint2: cp2)
            path.close()
            return path
        }
        
        // ─── MAIN WAVE — solid purple top section ───
        context.saveGState()
        
        let mainLeftY: CGFloat
        let mainRightY: CGFloat
        let mainCP1: CGPoint
        let mainCP2: CGPoint
        
        if isInverted {
            // Inverted: right side is high, left side dips — mirror of normal
            mainLeftY  = waveBaseY - amplitude * 0.22
            mainRightY = waveBaseY + amplitude * 0.18
            mainCP1 = CGPoint(x: width * 0.35 - phaseShift * 0.50,
                              y: waveBaseY + amplitude * 0.72)
            mainCP2 = CGPoint(x: width * 0.72 - phaseShift,
                              y: waveBaseY - amplitude * 0.70)
        } else {
            // Normal: left side is high, right side dips
            mainLeftY  = waveBaseY + amplitude * 0.30
            mainRightY = waveBaseY - amplitude * 0.30
            mainCP1 = CGPoint(x: width * 0.65 + phaseShift,
                              y: waveBaseY + amplitude * 1.10)
            mainCP2 = CGPoint(x: width * 0.28 + phaseShift * 0.50,
                              y: waveBaseY - amplitude * 0.90)
        }
        
        let mainPath = wavePath(leftY: mainLeftY, rightY: mainRightY, cp1: mainCP1, cp2: mainCP2)
        mainPath.addClip()
        
        let mainColors = [
            UIColor(red: 183/255, green: 180/255, blue: 240/255, alpha: 1.0).cgColor,
            UIColor(red: 205/255, green: 202/255, blue: 248/255, alpha: 1.0).cgColor
        ] as CFArray
        let mainGrad = CGGradient(colorsSpace: colorSpace, colors: mainColors, locations: nil)!
        context.drawLinearGradient(mainGrad,
                                   start: .zero,
                                   end: CGPoint(x: width, y: max(mainLeftY, mainRightY)),
                                   options: [])
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

    var swipeOffset: CGFloat = 0.0 {
        didSet {
            containerView.swipeOffset = swipeOffset
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
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
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
        leftImageView.contentMode = .scaleAspectFit
        leftImageView.clipsToBounds = false
        containerView.addSubview(leftImageView)
        
        rightImageView.translatesAutoresizingMaskIntoConstraints = false
        rightImageView.contentMode = .scaleAspectFit
        rightImageView.clipsToBounds = false
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
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 31),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.topAnchor, constant: 120),
            
            // Description constraints (centered in lower white section)
            descriptionLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 40),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // Left character: bottom-left, flush to card bottom edge
            leftImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            leftImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            leftImageView.widthAnchor.constraint(equalToConstant: 126),
            leftImageView.heightAnchor.constraint(equalToConstant: 81),
            
            // Right character: bottom-right, flush to card bottom edge
            rightImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            rightImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            rightImageView.widthAnchor.constraint(equalToConstant: 112),
            rightImageView.heightAnchor.constraint(equalToConstant: 77)
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
