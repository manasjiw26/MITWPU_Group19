//
//  MemoryJarScene.swift
//  Project Love 2.0
//
//  Created by SDC-USER on 06/01/26.
//

import Foundation
import SpriteKit
import CoreMotion


class MemoryJarScene: SKScene,SKPhysicsContactDelegate{
    
    // This defines the physics world
    // Purane variables ke niche ye naya variable add karo
    var motionData: CMAcceleration?
    let opQueue = OperationQueue() // Background queue for motion
    var jarCap: SKSpriteNode?
    let heartTexture = SKTexture(imageNamed: "heart_icon")
    var sharedHeartPhysicsBody: SKPhysicsBody?
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .clear
        
        let jarPath = UIBezierPath()

        // 1. Neck ke Top Center se shuru karein (Top Left corner of neck)
        jarPath.move(to: CGPoint(x: size.width * 0.215, y: size.height * 0.95))
        jarPath.addLine(to: CGPoint(x: size.width * 0.215, y: size.height * 0.90))

        // 2. Left Wall niche ki taraf (Belly tak aate hue wide ho rahi hai)
        jarPath.addLine(to: CGPoint(x: size.width * 0.094, y: size.height * 0.73))
        jarPath.addLine(to: CGPoint(x: size.width * 0.094, y: size.height * 0.22))

        // 3. Bottom LEFT CURVE (Very Round)
        // Is control point se bottom bilkul gol banega
        jarPath.addQuadCurve(to: CGPoint(x: size.width * 0.34, y: size.height * 0.065),
                             controlPoint: CGPoint(x: size.width * 0.09, y: size.height * 0.09))
        jarPath.addLine(to: CGPoint(x: size.width * 0.66, y: size.height * 0.065))
        // 4. Bottom RIGHT CURVE (Mirror image)
        jarPath.addQuadCurve(to: CGPoint(x: size.width * 0.906, y: size.height * 0.22),
                             controlPoint: CGPoint(x: size.width * 0.91, y: size.height * 0.09))

        // 5. Right Wall wapas neck tak
        jarPath.addLine(to: CGPoint(x: size.width * 0.906, y: size.height * 0.73))
        
        jarPath.addLine(to: CGPoint(x: size.width * 0.785, y: size.height * 0.90))
        jarPath.addLine(to: CGPoint(x: size.width * 0.785, y: size.height * 0.95))

        // 6. TOP CLOSURE: Neck ko upar se jodne ke liye
        jarPath.addLine(to: CGPoint(x: size.width * 0.214, y: size.height * 0.95))
//        jarPath.close()

        let jarBody = SKPhysicsBody(edgeChainFrom: jarPath.cgPath)
        jarBody.isDynamic = false
        jarBody.friction = 1.0
        jarBody.restitution = 0.0
        self.physicsBody = jarBody
        
        jarBody.categoryBitMask = PhysicsCategory.jar
        jarBody.collisionBitMask = PhysicsCategory.heart
        
        self.physicsWorld.contactDelegate = self
        jarBody.contactTestBitMask = PhysicsCategory.heart
        startGravityControl()
        
        setupJarCap()
        
    };

    func setupJarCap() {
        let capTexture = SKTexture(imageNamed: "jar_cap_icon2")
        
        if UIImage(named: "jar_cap_icon2") == nil {
                print("❌ Error: Cap image jar_cap_icon not found in Assets!")
                return
            }
        jarCap = SKSpriteNode(texture: capTexture)
        
        // Jar ki neck (gardann) ke hisaab se size set karein
        // Aapki image ke mutabiq width 0.60 aur height 40-50 sahi rahegi
        jarCap?.size = CGSize(width: size.width * 1.4, height: 80)
        
        // Iski position jar ki top line (0.90) ke thoda upar honi chahiye
        jarCap?.position = CGPoint(x: size.width * 0.482, y: size.height * 0.92)
        jarCap?.zPosition = 10 // Hearts ke piche na chhup jaye
        
        // Cap Physics (Static body taaki hearts takra kar ise niche na gira dein)
        
        jarCap?.physicsBody?.isDynamic = false
        
        if let cap = jarCap {
            addChild(cap)
        }
    }
    func animateCapOpening() {
        // 1. Upward move (EaseOut se animation natural lagti hai)
        let moveUp = SKAction.moveBy(x: 0, y: 60, duration: 0.3)
        moveUp.timingMode = .easeOut
        
        // 2. Thoda wait karein taaki heart andar ja sake
        let wait = SKAction.wait(forDuration: 0.6)
        
        // 3. Wapas apni purani jagah par (EaseIn se thoda fast band hoga)
        let moveDown = SKAction.moveBy(x: 0, y: -60, duration: 0.3)
        moveDown.timingMode = .easeIn
        
        let sequence = SKAction.sequence([moveUp, wait, moveDown])
        jarCap?.run(sequence)
    }
    func addHeart() {
        animateCapOpening()
        
        let delay = SKAction.wait(forDuration: 0.2)
        let dropAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            let heart = SKSpriteNode(texture: self.heartTexture)
            heart.size = CGSize(width: 50, height: 45)
            
            // 🔥 CHANGE: Ab heart 0.90 par paida hoga (Wall ke niche)
            // Isse Ghost mode ki zaroorat nahi padegi
            heart.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.88)
            
            if self.sharedHeartPhysicsBody == nil {
                self.sharedHeartPhysicsBody = SKPhysicsBody(texture: self.heartTexture, alphaThreshold: 0.5, size: heart.size)
            }
            heart.physicsBody = self.sharedHeartPhysicsBody?.copy() as? SKPhysicsBody
            
            // Seedha solid physics
            heart.physicsBody?.categoryBitMask = PhysicsCategory.heart
            heart.physicsBody?.collisionBitMask = PhysicsCategory.heart | PhysicsCategory.jar
            heart.physicsBody?.contactTestBitMask = PhysicsCategory.jar | PhysicsCategory.heart
            self.addChild(heart)
        }
        self.run(SKAction.sequence([delay, dropAction]))
    }
    let motionManager = CMMotionManager()

    func startGravityControl() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1 // Update 10 times per second
            motionManager.startAccelerometerUpdates(to: opQueue) { (data, error) in
                        self.motionData = data?.acceleration
                    }
        }
    }
    func didBegin(_ contact: SKPhysicsContact) {
        // Check karein ki kya heart takraya hai
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == (PhysicsCategory.heart | PhysicsCategory.jar) {
            // 1. Jab heart GLASS (Jar Wall) se takraye - Light Haptic
//            run(SKAction.playSoundFileNamed("glass_tap.mp3", waitForCompletion: false))
            triggerHaptic(style: .light)
        } else if collision == (PhysicsCategory.heart | PhysicsCategory.heart) {
            // 2. Jab heart DOOSRE HEART se takraye - Extra Light/Soft Haptic
            triggerHaptic(style: .soft)
        }
    }

    func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    override func update(_ currentTime: TimeInterval) {
        if let accel = motionData {
            // Gravity update loop ke andar makkhan chalegi
            self.physicsWorld.gravity = CGVector(dx: accel.x * 12, dy: accel.y * 12)
        }
    }
}
