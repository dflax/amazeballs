//
//  BallScene.swift
//  AmazeBalls
//
//  Created by Daniel Flax on 5/19/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion

class BallScene: SKScene, SKPhysicsContactDelegate {

	var contentCreated      : Bool!
	var currentGravity      : Float!
	var activeBall          : Int!
	var bouncyness          : Float!
	var boundingWall        : Bool!
	var accelerometerSetting: Bool!

	let motionManager: CMMotionManager = CMMotionManager()

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder) is not used in this app")
	}

	override init(size: CGSize) {
		super.init(size: size)
	}

	override func didMoveToView(view: SKView) {

		// Set the overall physicsWorld and outer wall characteristics
//		physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
		physicsWorld.contactDelegate = self
//		physicsBody = SKPhysicsBody(edgeLoopFromRect: ScreenRect)
		physicsBody?.categoryBitMask = CollisionCategories.EdgeBody

		// Load the brickwall background
		let wallTexture = SKTexture(imageNamed: "brickwall")
		let wallSprite  = SKSpriteNode(texture: wallTexture)
		wallSprite.size = ScreenSize
		wallSprite.position = ScreenCenter
		wallSprite.zPosition = -10
		self.addChild(wallSprite)

		// Load the floor for the bottom of the scene
		let floor = Floor()
		floor.zPosition = 100

		self.addChild(floor)

		updateWorldPhysicsSettings()
	}

	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {

		// Go though all touch points in the set
		for touch in (touches as! Set<UITouch>) {
			let location = touch.locationInNode(self)

			println("Drop ball in at \(location)")

			// If it's not already a ball, drop a new ball at that location
			self.addChild(Ball(location: location, ballType: activeBall, bouncyness: CGFloat(bouncyness)))

			if touch.tapCount == 2 {
				self.stopBalls()
			}
		}
	}

	//MARK: - Detect Collisions and Handle
	
	// SKPhysicsContactDelegate - to handle collisions between objects
	func didBeginContact(contact: SKPhysicsContact) {
		
		var firstBody: SKPhysicsBody
		var secondBody: SKPhysicsBody
		if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
			firstBody = contact.bodyA
			secondBody = contact.bodyB
		} else {
			firstBody = contact.bodyB
			secondBody = contact.bodyA
		}
		
		// Check if the collision is between Ball and Floor
		if ((firstBody.categoryBitMask & CollisionCategories.Ball != 0) && (secondBody.categoryBitMask & CollisionCategories.Floor != 0)) {
			// Ball and Floor collided
//			println("Ball and Floor collided")
		}

		// Checck if the collision is between Ball and Floor
		if ((firstBody.categoryBitMask & CollisionCategories.Ball != 0) && (secondBody.categoryBitMask & CollisionCategories.EdgeBody != 0)) {
//			println("Ball and wall collide")
		}
	}

	// Stop all balls from moving
	func stopBalls() {
		self.enumerateChildNodesWithName("ball") {
			node, stop in
			node.speed = 0
		}
	}

	// Use to remove any balls that have fallen off the screen
	override func update(currentTime: CFTimeInterval) {
	}

	// Loop through all ballNodes, and execute the passed in block if they've falled more than 500 points below the screen, they aren't coming back.
	override func didSimulatePhysics() {
		self.enumerateChildNodesWithName("ball") {
			node, stop in
			if node.position.y < -500 {
				node.removeFromParent()
			}
		}
	}

	//MARK: - Settings for the Physics World
	
	// This is the main method to update the physics for the scene based on the settings the user has entered on the Settings View.
	func updateWorldPhysicsSettings() {

		// Grab the standard user defaults handle
		let userDefaults = NSUserDefaults.standardUserDefaults()

		// Pull values for the different settings. Substitute in defaults if the NSUserDefaults doesn't include any value
		currentGravity       = userDefaults.valueForKey("gravityValue")         != nil ? userDefaults.valueForKey("gravityValue")         as! Float : -9.8
		activeBall           = userDefaults.valueForKey("activeBall")           != nil ? userDefaults.valueForKey("activeBall")           as! Int   : 2000
		bouncyness           = userDefaults.valueForKey("bouncyness")           != nil ? userDefaults.valueForKey("bouncyness")           as! Float : 0.5
		boundingWall         = userDefaults.valueForKey("boundingWallSetting")  != nil ? userDefaults.valueForKey("boundingWallSetting")  as! Bool  : false
		accelerometerSetting = userDefaults.valueForKey("accelerometerSetting") != nil ? userDefaults.valueForKey("accelerometerSetting") as! Bool  : false

		// If no Accelerometer, set the simple gravity for the world
		if (!accelerometerSetting) {
			physicsWorld.gravity = CGVector(dx: 0.0, dy: CGFloat(currentGravity))

			// In case it's on, turn off the accelerometer
			motionManager.stopAccelerometerUpdates()
		} else {

			// Turn on the accelerometer to handle setting the gravityself
			startComplexGravity()
		}

		// Loop through all balls and update their bouncyness values
		self.enumerateChildNodesWithName("ball") {
			node, stop in
			node.physicsBody?.restitution = CGFloat(self.bouncyness)
		}

		// Set whether there is a bounding wall (edge loop) around the frame
		if boundingWall == true {
			self.physicsBody = SKPhysicsBody(edgeLoopFromRect: ScreenRect)
		} else {
			self.physicsBody = nil
		}
	}

	//MARK: - Accelerate Framework Methods

	// If the user selects to have the accelerometer active, complex gravity must be calculated whenever the Core Motion delegate is called
	func startComplexGravity() {

		// Check if the accelerometer is available
		if (motionManager.accelerometerAvailable) {
			motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue()) {
				(data, error) in

				// Take the x and y acceleration vectors and multiply by the gravity values to come up with a full gravity vector
				let xGravity = CGFloat(data.acceleration.x) * CGFloat(self.currentGravity)
				let yGravity = CGFloat(data.acceleration.y) * CGFloat(self.currentGravity)
				self.physicsWorld.gravity = CGVector(dx: yGravity, dy: xGravity)
			}
		}
	}
	
				
}

