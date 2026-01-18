import SpriteKit
import Foundation
import WatchKit
import CoreMotion

/**
 * WatchBallPhysicsScene
 *
 * A simplified SpriteKit scene for watchOS that mirrors the core gameplay:
 * - Brick background
 * - Floor at the bottom of the display
 * - Toggleable left/right/top walls
 * - Press & hold to grow a preview ball; release to drop
 * - Fixed gravity (down toward bottom of display), no rotation
 * - Haptics on bounces, no audio
 */
class WatchBallPhysicsScene: SKScene, SKPhysicsContactDelegate {
    struct PhysicsCategory {
        static let ball: UInt32 = 0b0001
        static let floor: UInt32 = 0b0010
        static let wall: UInt32 = 0b0100
    }

    // Floor & walls
    private var floorSprite: SKSpriteNode!
    private var leftWallSprite: SKSpriteNode?
    private var rightWallSprite: SKSpriteNode?
    private var topWallSprite: SKSpriteNode?

    // Background
    private var backgroundSprite: SKSpriteNode!

    // Balls
    private var activeBalls: [SKShapeNode] = []
    private var maxBalls: Int = 8 // adjustable cap for watch

    // Preview
    private var previewBall: SKShapeNode? = nil
    private var previewStartTime: TimeInterval? = nil
    private var previewTargetRadius: CGFloat = 40 // updated on didChangeSize

    // Settings (local to watch)
    private(set) var wallsEnabled: Bool = true

    private let motionManager = CMMotionManager()

    // MARK: - Lifecycle

    override func sceneDidLoad() {
        super.sceneDidLoad()
        scaleMode = .resizeFill

        setupScene()
        setupPhysics()
        setupBackground()
        setupFloor()
        setupWalls()
        
        wallsEnabled = true
        updateWalls(enabled: true)

        // Start with zero gravity - only accelerometer will drive gravity
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 30.0
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
                guard let self = self, let a = data?.acceleration else { return }
                // On watchOS: a.x increases toward the digital crown when crown-up.
                // a.y increases toward the top of the watch face.
                // Map accelerometer directly to gravity with no bias.
                let rawX = CGFloat(a.x)
                let rawY = CGFloat(a.y)
                
                // Scale factor for gravity strength (adjust to taste)
                let gravityScale: CGFloat = 9.8
                
                // Map device acceleration to scene gravity
                // Reverse X so crown-up tilts balls toward bottom edge
                let dx = -rawX * gravityScale
                // Reverse Y so tilting watch back pulls balls down
                let dy = -rawY * gravityScale
                
                self.physicsWorld.gravity = CGVector(dx: dx, dy: dy)
            }
        }
        #if DEBUG
        print("WatchBallPhysicsScene: sceneDidLoad size=\(size)")
        #endif
    }

    deinit {
        if motionManager.isAccelerometerActive {
            motionManager.stopAccelerometerUpdates()
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        #if DEBUG
        print("WatchBallPhysicsScene: didChangeSize -> new size=\(size)")
        #endif
        super.didChangeSize(oldSize)
        // Update background
        if backgroundSprite != nil {
            backgroundSprite.size = size
            backgroundSprite.position = CGPoint(x: size.width/2, y: size.height/2)
            backgroundSprite.removeAllChildren()
            addBrickPattern(to: backgroundSprite)
        }
        // Update floor
        if floorSprite != nil {
            let floorHeight: CGFloat = 10
            let floorWidth = size.width * 0.96
            floorSprite.size = CGSize(width: floorWidth, height: floorHeight)
            floorSprite.position = CGPoint(x: size.width/2, y: floorHeight/2)
            floorSprite.physicsBody = SKPhysicsBody(rectangleOf: floorSprite.size)
            floorSprite.physicsBody?.isDynamic = false
            floorSprite.physicsBody?.categoryBitMask = PhysicsCategory.floor
            floorSprite.physicsBody?.collisionBitMask = PhysicsCategory.ball
        }
        // Update walls
        updateWallsGeometry()
        wallsEnabled = true
        updateWalls(enabled: true)

        // Update preview target: max 35% of min dimension
        let maxDiameter = min(size.width, size.height) * 0.35
        previewTargetRadius = maxDiameter / 2.0
    }

    // MARK: - Setup

    private func setupScene() {
        backgroundColor = .clear // brick background sprite covers full scene
        anchorPoint = CGPoint(x: 0, y: 0)
    }

    private func setupPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.speed = 1.0
    }

    private func setupBackground() {
        backgroundSprite = SKSpriteNode(color: SKColor.brown, size: size)
        backgroundSprite.position = CGPoint(x: size.width/2, y: size.height/2)
        backgroundSprite.zPosition = -100
        addBrickPattern(to: backgroundSprite)
        addChild(backgroundSprite)
    }

    private func addBrickPattern(to background: SKSpriteNode) {
        let brickWidth: CGFloat = 20
        let brickHeight: CGFloat = 10
        let mortarWidth: CGFloat = 1
        let rows = Int(size.height / (brickHeight + mortarWidth)) + 1
        let cols = Int(size.width / (brickWidth + mortarWidth)) + 1
        for row in 0..<rows {
            for col in 0..<cols {
                let offsetX = (row % 2 == 0) ? 0 : brickWidth / 2
                let x = CGFloat(col) * (brickWidth + mortarWidth) + offsetX - size.width / 2
                let y = CGFloat(row) * (brickHeight + mortarWidth) - size.height / 2
                let rect = CGRect(x: -brickWidth/2, y: -brickHeight/2, width: brickWidth, height: brickHeight)
                let brick = SKShapeNode(rect: rect)
                brick.fillColor = SKColor.red
                brick.strokeColor = SKColor.darkGray
                brick.lineWidth = 0.5
                brick.position = CGPoint(x: x, y: y)
                background.addChild(brick)
            }
        }
    }

    private func setupFloor() {
        let floorHeight: CGFloat = 10
        let floorWidth = size.width * 0.96
        floorSprite = SKSpriteNode(color: SKColor.darkGray, size: CGSize(width: floorWidth, height: floorHeight))
        floorSprite.position = CGPoint(x: size.width/2, y: floorHeight/2)
        floorSprite.zPosition = 10
        floorSprite.physicsBody = SKPhysicsBody(rectangleOf: floorSprite.size)
        floorSprite.physicsBody?.isDynamic = false
        floorSprite.physicsBody?.categoryBitMask = PhysicsCategory.floor
        floorSprite.physicsBody?.collisionBitMask = PhysicsCategory.ball
        addChild(floorSprite)
    }

    private func setupWalls() {
        let t: CGFloat = 6
        leftWallSprite = createWall(size: CGSize(width: t, height: size.height), position: CGPoint(x: t/2, y: size.height/2))
        rightWallSprite = createWall(size: CGSize(width: t, height: size.height), position: CGPoint(x: size.width - t/2, y: size.height/2))
        topWallSprite = createWall(size: CGSize(width: size.width, height: t), position: CGPoint(x: size.width/2, y: size.height - t/2))
        if let n = leftWallSprite { addChild(n) }
        if let n = rightWallSprite { addChild(n) }
        if let n = topWallSprite { addChild(n) }
        updateWallsGeometry()
        updateWalls(enabled: wallsEnabled)
    }

    private func createWall(size: CGSize, position: CGPoint) -> SKSpriteNode {
        let wall = SKSpriteNode(color: SKColor.gray, size: size)
        wall.position = position
        wall.zPosition = 5
        wall.physicsBody = SKPhysicsBody(rectangleOf: size)
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        wall.physicsBody?.collisionBitMask = PhysicsCategory.ball
        wall.physicsBody?.restitution = 0.98
        wall.physicsBody?.friction = 0.1
        return wall
    }

    private func updateWallsGeometry() {
        let t: CGFloat = 6
        if let left = leftWallSprite {
            left.size = CGSize(width: t, height: size.height)
            left.position = CGPoint(x: t/2, y: size.height/2)
            left.physicsBody = SKPhysicsBody(rectangleOf: left.size)
            left.physicsBody?.isDynamic = false
            left.physicsBody?.categoryBitMask = wallsEnabled ? PhysicsCategory.wall : 0
            left.physicsBody?.collisionBitMask = PhysicsCategory.ball
            left.physicsBody?.restitution = 0.98
            left.physicsBody?.friction = 0.1
        }
        if let right = rightWallSprite {
            right.size = CGSize(width: t, height: size.height)
            right.position = CGPoint(x: size.width - t/2, y: size.height/2)
            right.physicsBody = SKPhysicsBody(rectangleOf: right.size)
            right.physicsBody?.isDynamic = false
            right.physicsBody?.categoryBitMask = wallsEnabled ? PhysicsCategory.wall : 0
            right.physicsBody?.collisionBitMask = PhysicsCategory.ball
            right.physicsBody?.restitution = 0.98
            right.physicsBody?.friction = 0.1
        }
        if let top = topWallSprite {
            top.size = CGSize(width: size.width, height: t)
            top.position = CGPoint(x: size.width/2, y: size.height - t/2)
            top.physicsBody = SKPhysicsBody(rectangleOf: top.size)
            top.physicsBody?.isDynamic = false
            top.physicsBody?.categoryBitMask = wallsEnabled ? PhysicsCategory.wall : 0
            top.physicsBody?.collisionBitMask = PhysicsCategory.ball
            top.physicsBody?.restitution = 0.98
            top.physicsBody?.friction = 0.1
        }
    }

    private func updateWalls(enabled: Bool) {
        leftWallSprite?.isHidden = !enabled
        rightWallSprite?.isHidden = !enabled
        topWallSprite?.isHidden = !enabled
        if enabled {
            leftWallSprite?.physicsBody?.categoryBitMask = PhysicsCategory.wall
            rightWallSprite?.physicsBody?.categoryBitMask = PhysicsCategory.wall
            topWallSprite?.physicsBody?.categoryBitMask = PhysicsCategory.wall
        } else {
            leftWallSprite?.physicsBody?.categoryBitMask = 0
            rightWallSprite?.physicsBody?.categoryBitMask = 0
            topWallSprite?.physicsBody?.categoryBitMask = 0
        }
    }

    // MARK: - Ball creation

    private func createBallNode(radius: CGFloat) -> SKShapeNode {
        // Random size between 20% and 100% of previewTargetRadius
        let minR = max(6, previewTargetRadius * 0.2)
        let maxR = max(minR, previewTargetRadius)
        let r = CGFloat.random(in: minR...maxR)
        let node = SKShapeNode(circleOfRadius: r)
        // Random color palette
        let palette: [SKColor] = [.orange, .blue, .green, .magenta, .yellow, .purple, .orange]
        node.fillColor = palette.randomElement() ?? .orange
        node.strokeColor = .black
        node.lineWidth = 1
        node.zPosition = 20  // Above floor (10) and walls (5)
        node.name = "ball"
        return node
    }

    private func configureBallPhysics(_ node: SKShapeNode) {
        let radius = max(node.frame.width, node.frame.height) / 2
        node.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        node.physicsBody?.isDynamic = true
        node.physicsBody?.categoryBitMask = PhysicsCategory.ball
        node.physicsBody?.collisionBitMask = PhysicsCategory.floor | PhysicsCategory.wall | PhysicsCategory.ball
        node.physicsBody?.contactTestBitMask = PhysicsCategory.floor | PhysicsCategory.wall | PhysicsCategory.ball
        node.physicsBody?.restitution = 0.98
        node.physicsBody?.friction = 0.3
        node.physicsBody?.linearDamping = 0.05
        node.physicsBody?.angularDamping = 0.05
        node.physicsBody?.allowsRotation = true
    }

    // MARK: - Public API for SwiftUI wrapper

    func dropBall(at point: CGPoint) {
        // Immediate drop with random size/color at the specified point
        let shape = createBallNode(radius: previewTargetRadius)
        shape.position = point
        configureBallPhysics(shape)
        shape.physicsBody?.isDynamic = true
        shape.physicsBody?.affectedByGravity = true
        if activeBalls.count >= maxBalls, let oldest = activeBalls.first {
            oldest.removeFromParent()
            activeBalls.removeFirst()
        }
        addChild(shape)
        activeBalls.append(shape)
        
        // Notify with current ball count
        NotificationCenter.default.post(name: .watchBallDropped, object: activeBalls.count)
        
        #if DEBUG
        print("WatchBallPhysicsScene: dropped ball at \(point) (activeBalls=\(activeBalls.count))")
        #endif
    }

    // MARK: - SKPhysicsContactDelegate (haptics only)

    func didBegin(_ contact: SKPhysicsContact) {
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if mask == (PhysicsCategory.ball | PhysicsCategory.floor) || mask == (PhysicsCategory.ball | PhysicsCategory.wall) {
            WKInterfaceDevice.current().play(.click)
        }
    }

    #if DEBUG
    /// Dumps a summary of scene children to help diagnose unknown visual artifacts
    func dumpSceneChildren(tag: String = "") {
        print("\n[WatchBallPhysicsScene] Dump Children \(tag.isEmpty ? "" : "(\(tag))"):")
        print("  scene size=\(size), gravity=\(physicsWorld.gravity)")
        let cats: (UInt32) -> String = { mask in
            var parts: [String] = []
            if (mask & PhysicsCategory.ball) != 0 { parts.append("ball") }
            if (mask & PhysicsCategory.floor) != 0 { parts.append("floor") }
            if (mask & PhysicsCategory.wall) != 0 { parts.append("wall") }
            return parts.isEmpty ? "none" : parts.joined(separator: "|")
        }
        for (idx, node) in children.enumerated() {
            let name = node.name ?? "(nil)"
            let typeName = String(describing: type(of: node))
            let frame = node.calculateAccumulatedFrame()
            let alpha = node.alpha
            let z = node.zPosition
            var phys = ""
            if let body = node.physicsBody {
                phys = " phys(cat: \(cats(body.categoryBitMask)), col: \(cats(body.collisionBitMask)))"
            }
            print("  [\(idx)] name='\(name)' type=\(typeName) frame=\(Int(frame.width))x\(Int(frame.height))@\(Int(frame.origin.x)),\(Int(frame.origin.y)) alpha=\(String(format: "%.2f", alpha)) z=\(z)\(phys)")
        }
        print("-- end dump --\n")
    }
    #endif
}
