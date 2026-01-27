import UIKit

struct BotAssets {
    
    // MARK: - Colors (Matched to Image)
    static let skinColor = UIColor(red: 0.71, green: 0.60, blue: 0.88, alpha: 1.0) // Pastel Lavender
    static let strokeColor = UIColor(red: 0.29, green: 0.18, blue: 0.38, alpha: 1.0) // Deep Grape
    static let strokeWidth: CGFloat = 2.0
    
    // MARK: - Asset Generators
    
    static var body: UIImage {
        return drawImage(size: CGSize(width: 60, height: 60)) { ctx, rect in
            let bodyPath = UIBezierPath()

            // Start at top center
            bodyPath.move(to: CGPoint(x: 30, y: 6))

            // Right side of rounded top
            bodyPath.addCurve(to: CGPoint(x: 57, y: 31),
                              controlPoint1: CGPoint(x: 44.5, y: 6),    // Wider, rounder top
                              controlPoint2: CGPoint(x: 57, y: 15))     // Bulge out quickly

            // Right side middle to bottom: maintain wide belly
            bodyPath.addCurve(to: CGPoint(x: 50.5, y: 50),
                              controlPoint1: CGPoint(x: 57, y: 41.5),   // Keep it wide
                              controlPoint2: CGPoint(x: 54.5, y: 48))   // Gentle curve to bottom

            // Bottom: wide, flat-ish base
            bodyPath.addCurve(to: CGPoint(x: 9.5, y: 50),
                              controlPoint1: CGPoint(x: 41.5, y: 56),   // Push bottom down and out
                              controlPoint2: CGPoint(x: 18.5, y: 56))   // Wide, soft base

            // Left bottom to middle: mirror right side
            bodyPath.addCurve(to: CGPoint(x: 3, y: 31),
                              controlPoint1: CGPoint(x: 5.5, y: 48),    // Round the corner
                              controlPoint2: CGPoint(x: 3, y: 41.5))    // Keep it wide

            // Left side back to top: complete the blob with rounded top
            bodyPath.addCurve(to: CGPoint(x: 30, y: 6),
                              controlPoint1: CGPoint(x: 3, y: 15),      // Bulge out quickly
                              controlPoint2: CGPoint(x: 15.5, y: 6))    // Wider, rounder top

            bodyPath.close()
                
                // Render Properties
                skinColor.setFill()
                strokeColor.setStroke()
                bodyPath.lineWidth = 2.0
                bodyPath.lineJoinStyle = .round // Softens any sharp math angles
                bodyPath.fill()
                bodyPath.stroke()
            
            // 3. Eyes (Positioned for the gumdrop face)
            strokeColor.setFill()
            let leftEye = UIBezierPath(ovalIn: CGRect(x: 18, y: 24, width: 6, height: 8))
            let rightEye = UIBezierPath(ovalIn: CGRect(x: 36, y: 24, width: 6, height: 8))
            leftEye.fill()
            rightEye.fill()
            
            // 4. Smile
            let mouth = UIBezierPath()
            mouth.move(to: CGPoint(x: 26, y: 36))
            mouth.addQuadCurve(to: CGPoint(x: 34, y: 36), controlPoint: CGPoint(x: 30, y: 40))
            mouth.lineWidth = 2.0
            mouth.lineCapStyle = .round
            mouth.stroke()
            
            // 5. Cheeks
            let cheekColor = UIColor(red: 1.0, green: 0.6, blue: 0.8, alpha: 0.4)
            cheekColor.setFill()
            let leftCheek = UIBezierPath(ovalIn: CGRect(x: 11, y: 30, width: 7, height: 4))
            let rightCheek = UIBezierPath(ovalIn: CGRect(x: 42, y: 30, width: 7, height: 4))
            leftCheek.fill()
            rightCheek.fill()
        }
    }
    
    // (Hand and Foot remain unchanged)
    static var hand: UIImage {
        return drawImage(size: CGSize(width: 16, height: 16)) { ctx, rect in
            let path = UIBezierPath(ovalIn: rect.insetBy(dx: 2, dy: 2))
            skinColor.setFill()
            strokeColor.setStroke()
            path.lineWidth = 2
            path.fill()
            path.stroke()
        }
    }
    
    static var foot: UIImage {
        return drawImage(size: CGSize(width: 20, height: 14)) { ctx, rect in
            let path = UIBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 2), cornerRadius: 6)
            skinColor.setFill()
            strokeColor.setStroke()
            path.lineWidth = 2
            path.fill()
            path.stroke()
        }
    }
    
    private static func drawImage(size: CGSize, drawing: (CGContext, CGRect) -> Void) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            drawing(context.cgContext, CGRect(origin: .zero, size: size))
        }
    }
}
