import UIKit

class RubberLimbView: UIView {
    
    enum BendDirection {
        case left  // Elbow points Left (For the Bot's Left Arm)
        case right // Elbow points Right (For the Bot's Right Arm)
    }
    
    // MARK: - Connections
    weak var startView: UIView? // Shoulder
    weak var endView: UIView?   // Hand
    
    // MARK: - Settings
    var bendDirection: BendDirection = .right
    var limbColor: UIColor = .black
    var limbWidth: CGFloat = 3.0
    var naturalLength: CGFloat = 30.0 // The ideal length of the arm
    
    private let shapeLayer = CAShapeLayer()
    private var displayLink: CADisplayLink?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.isUserInteractionEnabled = false
        self.backgroundColor = .clear
        
        shapeLayer.strokeColor = limbColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = limbWidth
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        layer.addSublayer(shapeLayer)
        
        // Run loop at 60 FPS
        displayLink = CADisplayLink(target: self, selector: #selector(updatePath))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc func updatePath() {
        guard let start = startView, let end = endView, let superview = self.superview else { return }
        
        // 1. Get Positions relative to this view
        let p0 = start.convert(CGPoint(x: start.bounds.midX, y: start.bounds.midY), to: superview)
        let p1 = end.convert(CGPoint(x: end.bounds.midX, y: end.bounds.midY), to: superview)
        
        // 2. Calculate Distance (Hypotenuse)
        let dx = p1.x - p0.x
        let dy = p1.y - p0.y
        let currentDist = hypot(dx, dy)
        
        // 3. Midpoint
        let midX = (p0.x + p1.x) / 2
        let midY = (p0.y + p1.y) / 2
        
        // 4. Calculate Normal Vector (Perpendicular to direction)
        // Standard normal (-dy, dx) points "Left" relative to the line
        var normalX = -dy
        var normalY = dx
        
        // Normalize vector to length of 1
        if currentDist > 0 {
            normalX /= currentDist
            normalY /= currentDist
        }
        
        // 5. Calculate "Bendiness" (Elbow Strength)
        // If arm is compressed (current < natural), bend MORE.
        // If arm is stretched (current > natural), bend LESS (straighten out).
        let compression = max(0, naturalLength - currentDist)
        
        // Base bend + extra bend from compression
        let bendFactor: CGFloat = 10.0 + (compression * 0.8)
        
        // 6. Apply Direction
        // If we want to bend Right, we invert the "Left" normal
        let directionMultiplier: CGFloat = (bendDirection == .left) ? 1.0 : -1.0
        
        let controlPoint = CGPoint(
            x: midX + (normalX * bendFactor * directionMultiplier),
            y: midY + (normalY * bendFactor * directionMultiplier)
        )
        
        // 7. Draw Curve
        let path = UIBezierPath()
        path.move(to: p0)
        path.addQuadCurve(to: p1, controlPoint: controlPoint)
        
        shapeLayer.path = path.cgPath
    }
    
    override func removeFromSuperview() {
        displayLink?.invalidate()
        super.removeFromSuperview()
    }
}
