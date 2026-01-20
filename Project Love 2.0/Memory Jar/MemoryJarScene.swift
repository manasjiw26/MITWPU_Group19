import Foundation
import SpriteKit
import CoreMotion

class MemoryJarScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    var motionData: CMAcceleration?
    let opQueue = OperationQueue()
    var jarCap: SKSpriteNode?
    var jarBodySprite: SKSpriteNode?
    let heartTexture = SKTexture(imageNamed: "heart_icon")
    var sharedHeartPhysicsBody: SKPhysicsBody?
    let motionManager = CMMotionManager()

    override func didMove(to view: SKView) {
        self.backgroundColor = .clear // Keeps the background transparent
        
        setupJarPhysics() 
        setupJarCap()
        
        startGravityControl()
        self.physicsWorld.contactDelegate = self
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

    func addHeart(index: Int, animate: Bool = false) {
        if animate { animateCapOpening() }

        let heart = SKSpriteNode(texture: heartTexture)
        heart.size = CGSize(width: 50, height: 45)
        heart.name = "heart_node" // Used for targeted clearing in ViewController
        heart.userData = ["index": index]
        heart.position = CGPoint(x: size.width / 2, y: size.height * 0.88)

        if sharedHeartPhysicsBody == nil {
            sharedHeartPhysicsBody = SKPhysicsBody(texture: heartTexture, alphaThreshold: 0.5, size: heart.size)
        }
        
        heart.physicsBody = sharedHeartPhysicsBody?.copy() as? SKPhysicsBody
        heart.physicsBody?.categoryBitMask = PhysicsCategory.heart
        heart.physicsBody?.collisionBitMask = PhysicsCategory.heart | PhysicsCategory.jar
        heart.physicsBody?.restitution = 0.3
        
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
            if node.name == "heart_node", let index = node.userData?["index"] as? Int {
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

    override func update(_ currentTime: TimeInterval) {
        if let accel = motionData {
            // Gravity follows phone tilt (y is inverted for natural feel)
            self.physicsWorld.gravity = CGVector(dx: accel.x * 12, dy: accel.y * -12)
        }
    }
}
