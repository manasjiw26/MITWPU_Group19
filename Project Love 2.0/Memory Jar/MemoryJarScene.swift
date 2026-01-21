import AVFoundation
import UIKit
import Foundation
import SpriteKit
import CoreMotion

class MemoryJarScene: SKScene, SKPhysicsContactDelegate {
    private var lastGlassHit: TimeInterval = 0
    private let glassHaptic = UIImpactFeedbackGenerator(style: .medium)
    
    // MARK: - Properties
    var motionData: CMAcceleration?
    let opQueue = OperationQueue()
    var jarCap: SKSpriteNode?
    var jarBodySprite: SKSpriteNode?
    let heartTexture = SKTexture(imageNamed: "heart_icon")
    let heartBodyTexture = SKTexture(imageNamed: "heart_body")
    
    var sharedHeartPhysicsBody: SKPhysicsBody?
    let motionManager = CMMotionManager()
    private var glassPlayer: AVAudioPlayer?
    private var lastHeartVelocity: CGVector = .zero
    override func didMove(to view: SKView) {
        self.backgroundColor = .clear
        glassHaptic.prepare()
        setupJarPhysics()
        setupJarCap()
        setupGlassSound()
        startGravityControl()
        self.physicsWorld.contactDelegate = self
    }
    private func setupGlassSound() {
        guard let url = Bundle.main.url(forResource: "Tink", withExtension: "caf") else {
            fatalError("❌ glass_tap.wav not found in bundle")
        }

        do {
            glassPlayer = try AVAudioPlayer(contentsOf: url)
            glassPlayer?.volume = 0.1
            glassPlayer?.prepareToPlay()
        } catch {
            fatalError("❌ Audio init failed")
        }
    }
    func didBegin(_ contact: SKPhysicsContact) {

        let now = CACurrentMediaTime()
        guard now - lastGlassHit > 0.25 else { return }

        let maskA = contact.bodyA.categoryBitMask
        let maskB = contact.bodyB.categoryBitMask

        let heartHitsJar =
            (maskA == PhysicsCategory.heart && maskB == PhysicsCategory.jar) ||
            (maskB == PhysicsCategory.heart && maskA == PhysicsCategory.jar)

        guard heartHitsJar else { return }

        // Get the HEART body (not the jar)
        let heartBody: SKPhysicsBody =
            (contact.bodyA.categoryBitMask == PhysicsCategory.heart)
            ? contact.bodyA
            : contact.bodyB

        let impactStrength = hypot(lastHeartVelocity.dx, lastHeartVelocity.dy)

        // ❌ ignore sliding / rolling
        guard impactStrength > 100 else { return }
       

        lastGlassHit = now

        glassHaptic.impactOccurred()
        glassPlayer?.play()
    }
    func setupJarPhysics() {
        // Using your original custom Bezier Path coordinates
        let jarPath = UIBezierPath()
        jarPath.move(to: CGPoint(x: size.width * 0.215, y: size.height * 0.95))
        jarPath.addLine(to: CGPoint(x: size.width * 0.215, y: size.height * 0.90))
        jarPath.addLine(to: CGPoint(x: size.width * 0.094, y: size.height * 0.73))
        jarPath.addLine(to: CGPoint(x: size.width * 0.094, y: size.height * 0.22))
        
        jarPath.addQuadCurve(to: CGPoint(x: size.width * 0.34, y: size.height * 0.065),
                             controlPoint: CGPoint(x: size.width * 0.09, y: size.height * 0.09))
        jarPath.addLine(to: CGPoint(x: size.width * 0.66, y: size.height * 0.065))
        
        jarPath.addQuadCurve(to: CGPoint(x: size.width * 0.906, y: size.height * 0.22),
                             controlPoint: CGPoint(x: size.width * 0.91, y: size.height * 0.09))
        
        jarPath.addLine(to: CGPoint(x: size.width * 0.906, y: size.height * 0.73))
        jarPath.addLine(to: CGPoint(x: size.width * 0.785, y: size.height * 0.90))
        jarPath.addLine(to: CGPoint(x: size.width * 0.785, y: size.height * 0.95))
        jarPath.addLine(to: CGPoint(x: size.width * 0.214, y: size.height * 0.95))

        let jarBody = SKPhysicsBody(edgeChainFrom: jarPath.cgPath)
        jarBody.isDynamic = false
        jarBody.friction = 1.0
        jarBody.restitution = 0.2
        jarBody.categoryBitMask = PhysicsCategory.jar
        jarBody.collisionBitMask = PhysicsCategory.heart
        jarBody.contactTestBitMask = PhysicsCategory.heart
        self.physicsBody = jarBody
    }

    func setupJarCap() {
        let capTexture = SKTexture(imageNamed: "jar_cap_icon2")
        jarCap = SKSpriteNode(texture: capTexture)
        jarCap?.size = CGSize(width: size.width * 1.4, height: 80)
        jarCap?.position = CGPoint(x: size.width * 0.482, y: size.height * 0.92)
        jarCap?.zPosition = 10
        jarCap?.name = "permanent_cap" // Protected name
        if let cap = jarCap { addChild(cap) }
    }

    // MARK: - Heart Management

    func addHeart(index: Int, memoryID: UUID, animate: Bool = false) {
        if animate { animateCapOpening() }

        let heart = SKSpriteNode(texture: heartTexture)
        heart.size = CGSize(width: 50, height: 45)
        heart.name = "heart_\(memoryID.uuidString)"
        heart.userData = ["index": index]
        heart.position = CGPoint(x: size.width / 2, y: size.height * 0.88)
        if sharedHeartPhysicsBody == nil {
            sharedHeartPhysicsBody = SKPhysicsBody(texture: heartBodyTexture, alphaThreshold: 0.5, size: heart.size)
        }
        heart.physicsBody = sharedHeartPhysicsBody?.copy() as? SKPhysicsBody
        heart.physicsBody?.categoryBitMask = PhysicsCategory.heart
        heart.physicsBody?.collisionBitMask = PhysicsCategory.heart | PhysicsCategory.jar
        heart.physicsBody?.contactTestBitMask = PhysicsCategory.jar
        heart.physicsBody?.restitution = 0.1
        heart.physicsBody?.linearDamping = 2.5
        heart.physicsBody?.angularDamping = 3.0
        addChild(heart)
    }

    func animateCapOpening() {
        let moveUp = SKAction.moveBy(x: 0, y: 60, duration: 0.3)
        let wait = SKAction.wait(forDuration: 0.6)
        let moveDown = SKAction.moveBy(x: 0, y: -60, duration: 0.3)
        jarCap?.run(SKAction.sequence([moveUp, wait, moveDown]))
    }

    // MARK: - Motion & Interactivity

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            if let name = node.name, name.hasPrefix("heart_") {

                let uuidString = String(name.dropFirst("heart_".count))
                guard let uuid = UUID(uuidString: uuidString) else { return }

                // ✅ find correct memory index dynamically
                guard let index = dataStore.savedMemories.firstIndex(where: { $0.id == uuid }) else { return }

                NotificationCenter.default.post(name: NSNotification.Name("OpenMemory"), object: index)
            }
        }
    }

    func startGravityControl() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: opQueue) { (data, _) in
                self.motionData = data?.acceleration
            }
        }
    }
    func removeHeart(memoryID: UUID) {
        let nodeName = "heart_\(memoryID.uuidString)"
        childNode(withName: nodeName)?.removeFromParent()
    }
    override func update(_ currentTime: TimeInterval) {
        if let accel = motionData {
            self.physicsWorld.gravity = CGVector(dx: accel.x * 12, dy: accel.y * 12)
        }

        for node in children {
            if let body = node.physicsBody,
               body.categoryBitMask == PhysicsCategory.heart {
                lastHeartVelocity = body.velocity
                break
            }
        }
    }
}
