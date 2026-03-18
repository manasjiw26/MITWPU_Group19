import AVFoundation
import UIKit
import Foundation
import SpriteKit
import CoreMotion

class MemoryJarScene: SKScene, SKPhysicsContactDelegate {
    private var lastGlassHit: TimeInterval = 0
    private let glassHaptic = UIImpactFeedbackGenerator(style: .medium)
    
    
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
    
    // Used when accelerometer move
    
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
            fatalError("glass_tap.wav not found in bundle")
        }

        do {
            glassPlayer = try AVAudioPlayer(contentsOf: url)
            glassPlayer?.volume = 0.1
            glassPlayer?.prepareToPlay()
        } catch {
            fatalError("Audio init failed")
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

        // Get the heart body
        let heartBody: SKPhysicsBody =
            (contact.bodyA.categoryBitMask == PhysicsCategory.heart)
            ? contact.bodyA
            : contact.bodyB

        let impactStrength = hypot(lastHeartVelocity.dx, lastHeartVelocity.dy)

        //  ignore sliding / rolling
        guard impactStrength > 100 else { return }
       

        lastGlassHit = now

        glassHaptic.impactOccurred()
        glassPlayer?.play()
    }
    
    
    func setupJarPhysics() {
        // set boundaries of jar
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
        jarCap?.name = "permanent_cap"
        if let cap = jarCap { addChild(cap) }
    }

    

    func addHeart(index: Int, memoryID: UUID, animate: Bool = false) {
        let spawnX: CGFloat
        let spawnY: CGFloat

        if animate {
            // New heart: fall through the cap opening — random X in the neck
            let neckLeft  = size.width * 0.28
            let neckRight = size.width * 0.72
            spawnX = CGFloat.random(in: neckLeft...neckRight)
            spawnY = size.height * 0.88
        } else {
            // Restoring existing hearts: place INSIDE the jar body at a random
            // position so they never start embedded in walls or in each other.
            // Use a loose grid: column alternates left/centre/right per index.
            let col    = index % 3
            let leftX  = size.width * 0.24
            let midX   = size.width * 0.50
            let rightX = size.width * 0.76
            let baseX: CGFloat = col == 0 ? leftX : (col == 1 ? midX : rightX)
            spawnX = baseX + CGFloat.random(in: -20...20)   // small jitter

            // Spread Y from near the bottom up, row by row (3 columns per row)
            let row       = index / 3
            let jarBottom = size.height * 0.14
            let rowHeight = size.height * 0.13
            spawnY = jarBottom + CGFloat(row) * rowHeight + CGFloat.random(in: 0...20)
        }

        let heart = SKSpriteNode(texture: heartTexture)
        heart.size = CGSize(width: 50, height: 45)
        heart.name = "heart_\(memoryID.uuidString)"
        heart.userData = ["index": index]
        heart.position = CGPoint(x: spawnX, y: spawnY)

        if sharedHeartPhysicsBody == nil {
            sharedHeartPhysicsBody = SKPhysicsBody(texture: heartBodyTexture,
                                                   alphaThreshold: 0.5, size: heart.size)
        }
        let body = sharedHeartPhysicsBody!.copy() as! SKPhysicsBody
        body.categoryBitMask    = PhysicsCategory.heart
        body.collisionBitMask   = PhysicsCategory.heart | PhysicsCategory.jar
        body.contactTestBitMask = PhysicsCategory.jar
        body.restitution        = 0.1
        body.linearDamping      = 2.5
        body.angularDamping     = 3.0

        if animate {
            // Freeze above the cap until it opens, then drop
            body.isDynamic = false
            heart.physicsBody = body
            addChild(heart)

            animateCapOpening()

            let wait = SKAction.wait(forDuration: 0.35)
            let drop = SKAction.run { heart.physicsBody?.isDynamic = true }
            heart.run(SKAction.sequence([wait, drop]))
        } else {
            heart.physicsBody = body
            addChild(heart)
        }
    }

    
    func animateCapOpening() {
        let moveUp = SKAction.moveBy(x: 0, y: 60, duration: 0.3)
        let wait = SKAction.wait(forDuration: 0.6)
        let moveDown = SKAction.moveBy(x: 0, y: -60, duration: 0.3)
        jarCap?.run(SKAction.sequence([moveUp, wait, moveDown]))
    }

    // when heart touched memory opens
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            if let name = node.name, name.hasPrefix("heart_") {

                let uuidString = String(name.dropFirst("heart_".count))
                guard let uuid = UUID(uuidString: uuidString) else { return }

                //  find correct memory index
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
            guard let body = node.physicsBody,
                  body.categoryBitMask == PhysicsCategory.heart else { continue }

            lastHeartVelocity = body.velocity

            // ── Anti-stuck rescue (conservative) ──────────────────────────────
            // Only fires when a heart has nearly-zero linear speed AND very high
            // spin — the exact signature of two bodies locked at the same position.
            // Normal settling hearts have low angular velocity, so the angSpeed
            // threshold of 2.5 leaves them alone entirely.
            let speed    = hypot(body.velocity.dx, body.velocity.dy)
            let angSpeed = abs(body.angularVelocity)

            guard speed < 3, angSpeed > 2.5 else { continue }

            // Per-heart cooldown — don't nudge the same heart more than once per second
            let lastNudge = node.userData?["lastNudge"] as? TimeInterval ?? 0
            guard currentTime - lastNudge > 1.0 else { continue }

            // Gentle push to separate them — just enough to break the deadlock
            let nudgeX = CGFloat.random(in: -20...20)
            let nudgeY = CGFloat.random(in:  10...30)
            body.applyImpulse(CGVector(dx: nudgeX, dy: nudgeY))
            body.angularVelocity = 0

            node.userData?["lastNudge"] = currentTime
        }
    }
}
