//
//  BallPhysicsScene.swift
//  Amazeballs
//
//  Created by Daniel Flax on 11/15/25.
//

import SpriteKit
#if !os(macOS)
import CoreMotion
#endif
import Foundation

/**
 * BallPhysicsScene
 * 
 * A SpriteKit scene that simulates realistic ball physics with configurable gravity,
 * boundary walls, and accelerometer support. Designed for the Amazeballs app.
 * 
 * ## Features
 * - Dynamic ball dropping with realistic physics
 * - Configurable gravity and bounciness
 * - Optional boundary walls (left, right, top)
 * - Accelerometer support for device-based gravity
 * - Efficient ball management with cleanup
 * - Integration with BallAssetManager for ball types
 * 
 * ## Usage
 * ```swift
 * let scene = BallPhysicsScene(size: view.bounds.size)
 * scene.updatePhysics(with: GameSettings.shared)
 * scene.dropBall(at: CGPoint(x: 100, y: 400), ballType: "football", settings: GameSettings.shared)
 * ```
 */
class BallPhysicsScene: SKScene {
    
    // MARK: - Physics Categories
    
    /// Physics collision categories for different objects
    struct PhysicsCategory {
        static let ball: UInt32 = 0b0001
        static let floor: UInt32 = 0b0010
        static let wall: UInt32 = 0b0100
        static let ceiling: UInt32 = 0b1000
    }
    
    // MARK: - Scene Elements
    
    /// Floor sprite at the bottom of the scene
    private var floorSprite: SKSpriteNode!
    
    /// Left wall boundary (optional)
    private var leftWallSprite: SKSpriteNode?
    
    /// Right wall boundary (optional)
    private var rightWallSprite: SKSpriteNode?
    
    /// Top wall/ceiling boundary (optional)
    private var topWallSprite: SKSpriteNode?
    
    /// Background sprite for brick texture
    private var backgroundSprite: SKSpriteNode!
    
    // MARK: - Motion Management
    
    #if !os(macOS)
    /// Core Motion manager for accelerometer
    private var motionManager: CMMotionManager?
    #endif
    
    /// Whether accelerometer is currently enabled
    private var isAccelerometerEnabled = false
    
    /// Default gravity vector when accelerometer is disabled
    private let defaultGravity = CGVector(dx: 0, dy: -9.8)
    
    // MARK: - Ball Management
    
    /// Array to keep track of all balls in the scene
    private var activeBalls: [SKSpriteNode] = []
    
    /// Maximum number of balls allowed in scene (for performance)
    private let maxBalls: Int = 50
    
    /// Ball asset manager for loading ball images
    private let ballAssetManager = BallAssetManager.shared

    /// Preview ball shown during press-and-hold sizing
    private var previewBall: SKSpriteNode? = nil
    private var previewBallType: String? = nil
    
    /// Timing for preview growth
    private var previewStartTime: TimeInterval? = nil
    private var previewDuration: TimeInterval = 2.0
    private var previewBaseScale: CGFloat = 0.5
    private var previewTargetScale: CGFloat = 5.0
    
    // MARK: - Settings Cache
    
    /// Cached settings to avoid repeated access
    private var currentGravityStrength: CGFloat = 1.0
    private var currentBounciness: CGFloat = 0.8
    private var wallsEnabled: Bool = true
    
    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        scaleMode = .resizeFill
        setupScene()
        setupPhysics()
        setupBackground()
        setupFloor()
        setupWalls()
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        cleanupMotionManager()
    }
    
    deinit {
        cleanupMotionManager()
        activeBalls.removeAll()
    }
    
    // MARK: - Scene Setup
    
    /**
     * Sets up the basic scene properties
     */
    private func setupScene() {
        // Set scene background color (will be covered by background sprite)
        backgroundColor = SKColor.systemBlue
        
        // Ensure scene has proper anchor point
        anchorPoint = CGPoint(x: 0, y: 0)
        
        #if DEBUG
        // Show physics bodies in debug mode
        if let view = view {
            view.showsPhysics = false // Set to true for debugging
            view.showsFPS = true
            view.showsNodeCount = true
        }
        #endif
    }
    
    /**
     * Configures the physics world
     */
    private func setupPhysics() {
        // Create physics world
        physicsWorld.gravity = defaultGravity
        
        // Set contact delegate for collision detection
        physicsWorld.contactDelegate = self
        
        // Configure world physics properties
        physicsWorld.speed = 1.0
    }
    
    /**
     * Sets up the background sprite with brick-like appearance
     */
    private func setupBackground() {
        // Create background sprite
        backgroundSprite = SKSpriteNode(color: SKColor.brown, size: size)
        backgroundSprite.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundSprite.zPosition = -100 // Behind everything else
        
        // Add simple brick pattern (will be replaced with proper texture later)
        addBrickPattern(to: backgroundSprite)
        
        addChild(backgroundSprite)
    }
    
    /**
     * Creates a simple brick pattern on the background sprite
     */
    private func addBrickPattern(to background: SKSpriteNode) {
        let brickWidth: CGFloat = 60
        let brickHeight: CGFloat = 30
        let mortarWidth: CGFloat = 2
        
        let rows = Int(size.height / (brickHeight + mortarWidth)) + 1
        let cols = Int(size.width / (brickWidth + mortarWidth)) + 1
        
        for row in 0..<rows {
            for col in 0..<cols {
                let offsetX = (row % 2 == 0) ? 0 : brickWidth / 2
                let x = CGFloat(col) * (brickWidth + mortarWidth) + offsetX - size.width / 2
                let y = CGFloat(row) * (brickHeight + mortarWidth) - size.height / 2
                
                // Create brick with border using SKShapeNode
                let brickRect = CGRect(x: -brickWidth/2, y: -brickHeight/2, width: brickWidth, height: brickHeight)
                let brick = SKShapeNode(rect: brickRect)
                brick.fillColor = SKColor.systemRed
                brick.strokeColor = SKColor.darkGray
                brick.lineWidth = 1
                brick.position = CGPoint(x: x, y: y)
                
                background.addChild(brick)
            }
        }
    }
    
    /**
     * Sets up the floor at the bottom of the scene
     */
    private func setupFloor() {
        let floorWidth = size.width * 0.95
        let floorHeight: CGFloat = 20
        
        // Create floor sprite
        floorSprite = SKSpriteNode(color: SKColor.darkGray, size: CGSize(width: floorWidth, height: floorHeight))
        floorSprite.position = CGPoint(x: size.width / 2, y: floorHeight / 2)
        floorSprite.zPosition = 10
        
        // Create physics body for floor
        floorSprite.physicsBody = SKPhysicsBody(rectangleOf: floorSprite.size)
        floorSprite.physicsBody?.isDynamic = false
        floorSprite.physicsBody?.categoryBitMask = PhysicsCategory.floor
        floorSprite.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        floorSprite.physicsBody?.collisionBitMask = PhysicsCategory.ball
        floorSprite.physicsBody?.restitution = 0.2 // Slightly bouncy floor
        floorSprite.physicsBody?.friction = 0.3
        
        addChild(floorSprite)
    }
    
    /**
     * Sets up the boundary walls (left, right, top)
     */
    private func setupWalls() {
        let wallThickness: CGFloat = 10
        
        // Left Wall
        leftWallSprite = createWall(
            size: CGSize(width: wallThickness, height: size.height),
            position: CGPoint(x: wallThickness / 2, y: size.height / 2)
        )
        
        // Right Wall
        rightWallSprite = createWall(
            size: CGSize(width: wallThickness, height: size.height),
            position: CGPoint(x: size.width - wallThickness / 2, y: size.height / 2)
        )
        
        // Top Wall (Ceiling)
        topWallSprite = createWall(
            size: CGSize(width: size.width, height: wallThickness),
            position: CGPoint(x: size.width / 2, y: size.height - wallThickness / 2)
        )
        
        // Add walls to scene (visibility will be controlled by updateWalls)
        if let leftWall = leftWallSprite { addChild(leftWall) }
        if let rightWall = rightWallSprite { addChild(rightWall) }
        if let topWall = topWallSprite { addChild(topWall) }
        
        // Initially set wall visibility based on default settings
        updateWallsGeometry()
        updateWalls(enabled: wallsEnabled)
    }
    
    /**
     * Creates a wall sprite with physics body
     */
    private func createWall(size wallSize: CGSize, position: CGPoint) -> SKSpriteNode {
        let wall = SKSpriteNode(color: SKColor.gray, size: wallSize)
        wall.position = position
        wall.zPosition = 5
        
        // Create physics body
        wall.physicsBody = SKPhysicsBody(rectangleOf: wallSize)
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        wall.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        wall.physicsBody?.collisionBitMask = PhysicsCategory.ball
        wall.physicsBody?.restitution = 0.8
        wall.physicsBody?.friction = 0.1
        
        return wall
    }
    
    /**
     * Updates walls geometry and physics
     */
    private func updateWallsGeometry() {
        let wallThickness: CGFloat = 10

        // Left wall
        if let leftWall = leftWallSprite {
            leftWall.size = CGSize(width: wallThickness, height: size.height)
            leftWall.position = CGPoint(x: wallThickness / 2, y: size.height / 2)
            leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.size)
            leftWall.physicsBody?.isDynamic = false
            leftWall.physicsBody?.categoryBitMask = wallsEnabled ? PhysicsCategory.wall : 0
            leftWall.physicsBody?.contactTestBitMask = PhysicsCategory.ball
            leftWall.physicsBody?.collisionBitMask = PhysicsCategory.ball
            leftWall.physicsBody?.restitution = 0.8
            leftWall.physicsBody?.friction = 0.1
        }

        // Right wall
        if let rightWall = rightWallSprite {
            rightWall.size = CGSize(width: wallThickness, height: size.height)
            rightWall.position = CGPoint(x: size.width - wallThickness / 2, y: size.height / 2)
            rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.size)
            rightWall.physicsBody?.isDynamic = false
            rightWall.physicsBody?.categoryBitMask = wallsEnabled ? PhysicsCategory.wall : 0
            rightWall.physicsBody?.contactTestBitMask = PhysicsCategory.ball
            rightWall.physicsBody?.collisionBitMask = PhysicsCategory.ball
            rightWall.physicsBody?.restitution = 0.8
            rightWall.physicsBody?.friction = 0.1
        }

        // Top wall
        if let topWall = topWallSprite {
            topWall.size = CGSize(width: size.width, height: wallThickness)
            topWall.position = CGPoint(x: size.width / 2, y: size.height - wallThickness / 2)
            topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
            topWall.physicsBody?.isDynamic = false
            topWall.physicsBody?.categoryBitMask = wallsEnabled ? PhysicsCategory.wall : 0
            topWall.physicsBody?.contactTestBitMask = PhysicsCategory.ball
            topWall.physicsBody?.collisionBitMask = PhysicsCategory.ball
            topWall.physicsBody?.restitution = 0.8
            topWall.physicsBody?.friction = 0.1
        }

        // Maintain visibility
        updateWalls(enabled: wallsEnabled)
    }
    
    // MARK: - Ball Management
    
    /**
     * Drops a ball at the specified position with given settings
     * 
     * - Parameters:
     *   - point: The position where the ball should be dropped
     *   - ballType: The type of ball (from BallAssetManager)
     *   - settings: Game settings containing physics parameters
     *   - sizeOverride: Optional size multiplier override for the ball
     */
    func dropBall(at point: CGPoint, ballType: String?, settings: GameSettings, sizeOverride: Double? = nil) {
        // Remove oldest ball if we've hit the limit
        if activeBalls.count >= maxBalls {
            removeOldestBall()
        }
        
        // Determine ball type (use random if not specified)
        let finalBallType = ballType ?? ballAssetManager.randomBallType() ?? "default"
        
        // Use size override if provided, otherwise use effectiveBallSize from settings
        let sizeMultiplier = CGFloat(sizeOverride ?? settings.effectiveBallSize())
        let ballSprite = createBallSprite(ballType: finalBallType, sizeMultiplier: sizeMultiplier)
        ballSprite.position = point
        
        // Configure physics based on settings
        configureBallPhysics(ballSprite, settings: settings)
        
        // Mark that this ball hasn't played its bounce sound yet
        if ballSprite.userData == nil {
            ballSprite.userData = NSMutableDictionary()
        }
        ballSprite.userData?["hasPlayedBounceSound"] = false
        
        // Add to scene and track
        addChild(ballSprite)
        activeBalls.append(ballSprite)
        
        #if DEBUG
        print("BallPhysicsScene: Dropped \(finalBallType) ball at \(point). Active balls: \(activeBalls.count)")
        #endif
    }
    
    /**
     * Begins showing a preview ball at the specified point with minimum size. The ball is static until committed.
     */
    func beginPreviewBall(at point: CGPoint, ballType: String?, settings: GameSettings) {
        // Remove any existing preview first
        if let existing = previewBall { existing.removeFromParent() }
        previewBall = nil
        previewBallType = ballType ?? ballAssetManager.randomBallType() ?? "default"

        // Create sprite at base size (use base texture size and scale down to 0.5x visually)
        let sprite = createBallSprite(ballType: previewBallType!, sizeMultiplier: 1.0)
        sprite.position = point
        sprite.zPosition = 1

        // Remove physics body during preview for performance
        sprite.physicsBody = nil

        // Set initial scale to min
        sprite.setScale(previewBaseScale)

        addChild(sprite)
        previewBall = sprite

        // Initialize timing based on current system time
        previewStartTime = CACurrentMediaTime()
        previewDuration = settings.pressAndGrowDuration
    }

    /**
     * Updates the preview ball's size based on progress 0.0...1.0
     */
    func updatePreviewBall(progress: Double) {
        // Optional: If external callers want to force a certain progress, we can set the scale directly.
        guard let sprite = previewBall else { return }
        let clamped = max(0.0, min(1.0, progress))
        let scale = previewBaseScale + (previewTargetScale - previewBaseScale) * CGFloat(clamped)
        sprite.setScale(scale)
    }

    /**
     * Commits the preview ball so it becomes dynamic and starts to fall. Also tracks it like a normal ball.
     */
    func commitPreviewBall(settings: GameSettings) {
        guard let sprite = previewBall else { return }

        // Build physics body at final radius based on current scale
        let baseSize: CGFloat = 40.0
        let currentScale = sprite.xScale
        let finalSize = CGSize(width: baseSize * currentScale, height: baseSize * currentScale)
        sprite.size = finalSize

        // Configure physics and enable dynamics
        configureBallPhysics(sprite, settings: settings)
        sprite.physicsBody?.isDynamic = true
        sprite.physicsBody?.affectedByGravity = true

        // Mark that this ball hasn't played its bounce sound yet
        if sprite.userData == nil {
            sprite.userData = NSMutableDictionary()
        }
        sprite.userData?["hasPlayedBounceSound"] = false
        
        // Track as an active ball and clear preview state
        activeBalls.append(sprite)
        
        previewBall = nil
        previewBallType = nil
        previewStartTime = nil
    }
    
    /**
     * Creates a ball sprite with the appropriate image
     */
    private func createBallSprite(ballType: String, sizeMultiplier: CGFloat = 1.0) -> SKSpriteNode {
        // Try to get ball image from asset manager
		_ = ballAssetManager.ballImageView(for: ballType)
        
        // Create sprite node
        // Note: For SpriteKit, we need to use the asset name directly
        let assetName = ballAssetManager.assetName(for: ballType)
        let ballSprite: SKSpriteNode
        
        #if os(macOS)
        if let nsImage = NSImage(named: assetName) {
            let texture = SKTexture(image: nsImage)
            ballSprite = SKSpriteNode(texture: texture)
        } else {
            ballSprite = SKSpriteNode(color: SKColor.orange, size: CGSize(width: 30, height: 30))
        }
        #else
        if let uiImage = UIImage(named: assetName) {
            let texture = SKTexture(image: uiImage)
            ballSprite = SKSpriteNode(texture: texture)
        } else {
            ballSprite = SKSpriteNode(color: SKColor.orange, size: CGSize(width: 30, height: 30))
        }
        #endif
        
        // Set size with multiplier (base size is 40x40)
        let baseSize: CGFloat = 40.0
        let ballSize = CGSize(width: baseSize * sizeMultiplier, height: baseSize * sizeMultiplier)
        ballSprite.size = ballSize
        ballSprite.zPosition = 1
        
        // Set name for identification
        ballSprite.name = "ball-\(ballType)"
        
        return ballSprite
    }
    
    /**
     * Configures physics properties for a ball sprite
     */
    private func configureBallPhysics(_ ballSprite: SKSpriteNode, settings: GameSettings) {
        let radius = min(ballSprite.size.width, ballSprite.size.height) / 2
        
        // Create circular physics body
        ballSprite.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        ballSprite.physicsBody?.isDynamic = true
        
        // Set physics categories
        ballSprite.physicsBody?.categoryBitMask = PhysicsCategory.ball
        ballSprite.physicsBody?.contactTestBitMask = PhysicsCategory.floor | PhysicsCategory.wall | PhysicsCategory.ball
        ballSprite.physicsBody?.collisionBitMask = PhysicsCategory.floor | PhysicsCategory.wall | PhysicsCategory.ball
        
        // Set physics properties based on settings
        ballSprite.physicsBody?.restitution = CGFloat(settings.bounciness)
        ballSprite.physicsBody?.friction = 0.3
        ballSprite.physicsBody?.linearDamping = 0.1
        ballSprite.physicsBody?.angularDamping = 0.1
        
        // Set mass and density for realistic physics
        ballSprite.physicsBody?.mass = 0.5
        ballSprite.physicsBody?.density = 1.0
        
        // Allow rotation
        ballSprite.physicsBody?.allowsRotation = true
    }
    
    /**
     * Removes the oldest ball from the scene
     */
    private func removeOldestBall() {
        guard let oldestBall = activeBalls.first else { return }
        
        oldestBall.removeFromParent()
        activeBalls.removeFirst()
        
        #if DEBUG
        print("BallPhysicsScene: Removed oldest ball. Remaining balls: \(activeBalls.count)")
        #endif
    }
    
    /**
     * Removes all balls from the scene
     */
    func clearAllBalls() {
        for ball in activeBalls {
            ball.removeFromParent()
        }
        activeBalls.removeAll()
        
        #if DEBUG
        print("BallPhysicsScene: Cleared all balls")
        #endif
    }
    
    // MARK: - Physics Updates
    
    /**
     * Updates physics settings based on game settings
     * 
     * - Parameter settings: Updated game settings
     */
    func updatePhysics(with settings: GameSettings) {
        // Cache settings for efficiency
        currentGravityStrength = CGFloat(settings.gravity)
        currentBounciness = CGFloat(settings.bounciness)
        wallsEnabled = settings.wallsEnabled
        
        // Update gravity if accelerometer is not active
        if !isAccelerometerEnabled {
            physicsWorld.gravity = CGVector(dx: 0, dy: -9.8 * currentGravityStrength)
        }
        
        // Update wall visibility
        updateWalls(enabled: wallsEnabled)
        
        // Update existing balls' restitution
        updateExistingBalls(bounciness: currentBounciness)
        
        #if DEBUG
        print("BallPhysicsScene: Updated physics - Gravity: \(currentGravityStrength), Bounciness: \(currentBounciness), Walls: \(wallsEnabled)")
        #endif
    }
    
    /**
     * Updates wall visibility and physics
     */
    private func updateWalls(enabled: Bool) {
        leftWallSprite?.isHidden = !enabled
        rightWallSprite?.isHidden = !enabled
        topWallSprite?.isHidden = !enabled
        
        // Disable physics when hidden
        leftWallSprite?.physicsBody?.categoryBitMask = enabled ? PhysicsCategory.wall : 0
        rightWallSprite?.physicsBody?.categoryBitMask = enabled ? PhysicsCategory.wall : 0
        topWallSprite?.physicsBody?.categoryBitMask = enabled ? PhysicsCategory.wall : 0
    }
    
    /**
     * Updates physics properties of existing balls
     */
    private func updateExistingBalls(bounciness: CGFloat) {
        for ball in activeBalls {
            ball.physicsBody?.restitution = bounciness
        }
    }
    
    // MARK: - Accelerometer Support
    
    /**
     * Enables or disables accelerometer-based gravity
     * 
     * - Parameter enabled: Whether accelerometer should be enabled
     */
    func enableAccelerometer(_ enabled: Bool) {
        if enabled {
            startAccelerometer()
        } else {
            stopAccelerometer()
        }
    }
    
    /**
     * Starts accelerometer monitoring
     */
    private func startAccelerometer() {
        guard !isAccelerometerEnabled else { return }
        
        #if os(macOS)
        // Accelerometer is not available on macOS
        #if DEBUG
        print("BallPhysicsScene: Accelerometer not available on macOS")
        #endif
        return
        #else
        // Check if accelerometer is available
        guard CMMotionManager().isAccelerometerAvailable else {
            #if DEBUG
            print("BallPhysicsScene: Accelerometer not available on this device")
            #endif
            return
        }
        
        motionManager = CMMotionManager()
        motionManager?.accelerometerUpdateInterval = 1.0 / 60.0 // 60 Hz
        
        motionManager?.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let accelerometerData = data, error == nil else {
                #if DEBUG
                print("BallPhysicsScene: Accelerometer error: \(error?.localizedDescription ?? "Unknown")")
                #endif
                return
            }
            
            self.updateGravityWithAccelerometer(data: accelerometerData)
        }
        
        isAccelerometerEnabled = true
        
        #if DEBUG
        print("BallPhysicsScene: Accelerometer enabled")
        #endif
        #endif
    }
    
    /**
     * Stops accelerometer monitoring
     */
    private func stopAccelerometer() {
        #if !os(macOS)
        motionManager?.stopAccelerometerUpdates()
        motionManager = nil
        #endif
        isAccelerometerEnabled = false
        
        // Restore default gravity
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8 * currentGravityStrength)
        
        #if DEBUG
        print("BallPhysicsScene: Accelerometer disabled")
        #endif
    }
    
    /**
     * Updates gravity based on accelerometer data
     * 
     * Transforms accelerometer data from device coordinates to scene coordinates
     * based on the current interface orientation. This ensures gravity always
     * points in the correct direction relative to the screen, not the physical device.
     */
    #if !os(macOS)
    private func updateGravityWithAccelerometer(data: CMAccelerometerData) {
        // Get the current interface orientation
        let orientation = getCurrentInterfaceOrientation()
        
        // Convert accelerometer data to gravity vector
        // The accelerometer reports the direction opposite to gravity, so we use the values directly
        let deviceX = data.acceleration.x
        let deviceY = data.acceleration.y
        
        // Transform from device coordinates to scene coordinates based on orientation
        // Device coordinates: X points toward right edge (when in portrait), Y points toward top
        // Scene coordinates: X points right on screen, Y points up on screen
        let (sceneX, sceneY) = transformAccelerometerToScene(deviceX: deviceX, deviceY: deviceY, orientation: orientation)
        
        // Apply gravity strength multiplier
        let gravityX = sceneX * 9.8 * currentGravityStrength
        let gravityY = sceneY * 9.8 * currentGravityStrength
        
        physicsWorld.gravity = CGVector(dx: gravityX, dy: gravityY)
        
        #if DEBUG
        // Uncomment for debugging gravity vectors
        // print("BallPhysicsScene: Accel(\(deviceX), \(deviceY)) -> Scene(\(sceneX), \(sceneY)) -> Gravity(\(gravityX), \(gravityY))")
        #endif
    }
    
    /**
     * Gets the current interface orientation from the scene's view
     * 
     * - Returns: The current UIInterfaceOrientation, or .landscapeLeft as fallback
     */
    private func getCurrentInterfaceOrientation() -> UIInterfaceOrientation {
        #if os(iOS)
        // Try to get orientation from the window scene's effective geometry
        if let windowScene = view?.window?.windowScene {
                return windowScene.effectiveGeometry.interfaceOrientation
        }
        #endif
        
        // Fallback to landscape left (the locked orientation for this app)
        return .landscapeLeft
    }
    
    /**
     * Transforms accelerometer coordinates from device space to scene space
     * 
     * Device coordinates are fixed relative to the physical device:
     * - X axis points toward the right edge when device is in portrait
     * - Y axis points toward the top edge when device is in portrait
     * - Z axis points out of the screen
     * 
     * Scene coordinates are relative to the current screen orientation:
     * - X axis points to the right of the screen (as currently oriented)
     * - Y axis points to the top of the screen (as currently oriented)
     * 
     * - Parameters:
     *   - deviceX: X component from accelerometer (device coordinates)
     *   - deviceY: Y component from accelerometer (device coordinates)
     *   - orientation: The current interface orientation
     * - Returns: A tuple (sceneX, sceneY) in scene coordinates
     */
    private func transformAccelerometerToScene(deviceX: Double, deviceY: Double, orientation: UIInterfaceOrientation) -> (Double, Double) {
        switch orientation {
        case .landscapeLeft:
            // Landscape Left: Home button (or charging port) on RIGHT
            // Device right edge (deviceX+) -> Screen bottom (sceneY-)
            // Device top edge (deviceY+) -> Screen right (sceneX+)
            // Therefore: sceneX = deviceY, sceneY = -deviceX
            return (deviceY, -deviceX)
            
        case .landscapeRight:
            // Landscape Right: Home button (or charging port) on LEFT
            // Device right edge (deviceX+) -> Screen top (sceneY+)
            // Device top edge (deviceY+) -> Screen left (sceneX-)
            // Therefore: sceneX = -deviceY, sceneY = deviceX
            return (-deviceY, deviceX)
            
        case .portrait:
            // Portrait: Home button at BOTTOM
            // Device right edge (deviceX+) -> Screen right (sceneX+)
            // Device top edge (deviceY+) -> Screen top (sceneY+)
            // Therefore: sceneX = deviceX, sceneY = deviceY
            return (deviceX, deviceY)
            
        case .portraitUpsideDown:
            // Portrait Upside Down: Home button at TOP
            // Device right edge (deviceX+) -> Screen left (sceneX-)
            // Device top edge (deviceY+) -> Screen bottom (sceneY-)
            // Therefore: sceneX = -deviceX, sceneY = -deviceY
            return (-deviceX, -deviceY)
            
        case .unknown:
            fallthrough
        @unknown default:
            // Fallback to landscape left (the app's locked orientation)
            return (deviceY, -deviceX)
        }
    }
    #endif
    
    /**
     * Cleanup motion manager resources
     */
    private func cleanupMotionManager() {
        if isAccelerometerEnabled {
            stopAccelerometer()
        }
    }
    
    // MARK: - Utility Methods
    
    /**
     * Returns the number of active balls in the scene
     */
    var activeBallCount: Int {
        return activeBalls.count
    }
    
    /**
     * Determines which sound should play for a given ball type
     * 
     * - Parameter ballType: The ball type identifier (e.g., "ball-basketball1")
     * - Returns: The sound identifier to play ("boing", "rubber-ball", "sports-ball", or "ping-pong-ball")
     */
    private func soundForBallType(_ ballType: String) -> String {
        switch ballType {
        case "ball-amazeball":
            return "boing"
            
        case "ball-apple1", "ball-banana1", "ball-banana2", "ball-banana3",
             "ball-cherries1", "ball-cherries2", "ball-egg1", "ball-olive1",
             "ball-peace1", "ball-peace2", "ball-pumpkin1":
            return "rubber-ball"
            
        case "ball-baseball1", "ball-baseball2", "ball-baseball3",
             "ball-basketball1", "ball-basketball2", "ball-basketball3",
             "ball-football1", "ball-football2", "ball-football3", "ball-football4",
             "ball-hockeypuck1",
             "ball-soccer1", "ball-soccer2", "ball-soccer3", "ball-soccer4", "ball-soccer5", "ball-soccer6",
             "ball-tennis1", "ball-tennis2", "ball-tennis3", "ball-tennis4", "ball-tennis5",
             "ball-volleyball1", "ball-volleyball2":
            return "sports-ball"
            
        case "ball-bowling1", "ball-bowling2", "ball-bowling3", "ball-bowling4",
             "ball-bowlingpin1", "ball-bowlingpins2",
             "ball-christmasball1", "ball-cookie1",
             "ball-discoball1", "ball-discoball2",
             "ball-eightball1",
             "ball-glassball1",
             "ball-golf1", "ball-golf2", "ball-golf3":
            return "ping-pong-ball"
            
        default:
            // Fallback for any unknown ball types
            return "rubber-ball"
        }
    }
    
    /**
     * Returns debug information about the scene
     */
    func debugInfo() -> [String: Any] {
        return [
            "activeBalls": activeBalls.count,
            "maxBalls": maxBalls,
            "gravity": physicsWorld.gravity,
            "accelerometerEnabled": isAccelerometerEnabled,
            "wallsEnabled": wallsEnabled,
            "currentGravity": currentGravityStrength,
            "currentBounciness": currentBounciness,
            "sceneSize": size
        ]
    }

    // MARK: - Size Change Handling

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)

        // Resize and reposition background
        if backgroundSprite != nil {
            backgroundSprite.size = size
            backgroundSprite.position = CGPoint(x: size.width / 2, y: size.height / 2)
            // Rebuild brick pattern to match new size
            backgroundSprite.removeAllChildren()
            addBrickPattern(to: backgroundSprite)
        }

        // Update floor geometry and physics
        if floorSprite != nil {
            let floorHeight: CGFloat = 20
            let floorWidth = size.width * 0.95
            floorSprite.size = CGSize(width: floorWidth, height: floorHeight)
            floorSprite.position = CGPoint(x: size.width / 2, y: floorHeight / 2)

            floorSprite.physicsBody = SKPhysicsBody(rectangleOf: floorSprite.size)
            floorSprite.physicsBody?.isDynamic = false
            floorSprite.physicsBody?.categoryBitMask = PhysicsCategory.floor
            floorSprite.physicsBody?.contactTestBitMask = PhysicsCategory.ball
            floorSprite.physicsBody?.collisionBitMask = PhysicsCategory.ball
            floorSprite.physicsBody?.restitution = 0.2
            floorSprite.physicsBody?.friction = 0.3
        }

        // Update walls geometry and physics
        updateWallsGeometry()
    }

    // MARK: - Frame Update

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        // Smoothly grow preview ball based on elapsed time
        if let sprite = previewBall, let start = previewStartTime {
            let elapsed = currentTime - start
            let total = max(0.1, previewDuration)
            let progress = max(0.0, min(1.0, elapsed / total))
            let scale = previewBaseScale + (previewTargetScale - previewBaseScale) * CGFloat(progress)
            sprite.setScale(scale)
        }
    }
}

// MARK: - SKPhysicsContactDelegate

extension BallPhysicsScene: SKPhysicsContactDelegate {
    
    /**
     * Called when two physics bodies begin contact
     */
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // Handle ball-floor contact
        if contactMask == (PhysicsCategory.ball | PhysicsCategory.floor) {
            handleBallFloorContact(contact)
        }
        
        // Handle ball-wall contact
        if contactMask == (PhysicsCategory.ball | PhysicsCategory.wall) {
            handleBallWallContact(contact)
        }
        
        // Handle ball-ball contact
        if contactMask == (PhysicsCategory.ball | PhysicsCategory.ball) {
            handleBallBallContact(contact)
        }
    }
    
    /**
     * Handles ball-floor collision
     */
    private func handleBallFloorContact(_ contact: SKPhysicsContact) {
        // Determine which body is the ball
        let ballNode = contact.bodyA.categoryBitMask == PhysicsCategory.ball ? contact.bodyA.node : contact.bodyB.node
        
        guard let ballSprite = ballNode as? SKSpriteNode else { return }
        
        // Check if this ball has already played its bounce sound
        guard let hasPlayed = ballSprite.userData?["hasPlayedBounceSound"] as? Bool,
              !hasPlayed else { return }
        
        // Mark as played
        ballSprite.userData?["hasPlayedBounceSound"] = true
        
        // Extract ball type from sprite name (format: "ball-basketball1")
        guard let ballName = ballSprite.name else { return }
        
        // Determine which sound to play
        let soundName = soundForBallType(ballName)
        
        // Calculate impact velocity for volume adjustment
        let velocity = ballSprite.physicsBody?.velocity ?? CGVector.zero
        let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
        let intensity = min(1.0, Double(speed) / 500.0) // Normalize to 0.0-1.0
        
        // Play the bounce sound
        SoundManager.shared.playBounceSound(soundName: soundName, intensity: intensity)
    }
    
    /**
     * Handles ball-wall collision
     */
    private func handleBallWallContact(_ contact: SKPhysicsContact) {
        // Determine which body is the ball
        let ballNode = contact.bodyA.categoryBitMask == PhysicsCategory.ball ? contact.bodyA.node : contact.bodyB.node
        
        guard let ballSprite = ballNode as? SKSpriteNode else { return }
        
        // Check if this ball has already played its bounce sound
        guard let hasPlayed = ballSprite.userData?["hasPlayedBounceSound"] as? Bool,
              !hasPlayed else { return }
        
        // Mark as played
        ballSprite.userData?["hasPlayedBounceSound"] = true
        
        // Extract ball type from sprite name (format: "ball-basketball1")
        guard let ballName = ballSprite.name else { return }
        
        // Determine which sound to play
        let soundName = soundForBallType(ballName)
        
        // Calculate impact velocity for volume adjustment
        let velocity = ballSprite.physicsBody?.velocity ?? CGVector.zero
        let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
        let intensity = min(1.0, Double(speed) / 500.0) // Normalize to 0.0-1.0
        
        // Play the bounce sound
        SoundManager.shared.playBounceSound(soundName: soundName, intensity: intensity)
    }
    
    /**
     * Handles ball-ball collision
     */
    private func handleBallBallContact(_ contact: SKPhysicsContact) {
        // Add any special ball-ball collision effects here
        // For now, just rely on SpriteKit's built-in physics
        
        #if DEBUG
        // Uncomment for debugging ball collisions
        // print("BallPhysicsScene: Ball-ball collision")
        #endif
    }
}

