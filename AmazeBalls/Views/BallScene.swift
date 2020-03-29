//
//  BallScene.swift
//  AmazeBalls
//
//  Created by Daniel Flax on 5/18/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//
//                        The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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

	override func didMove(to view: SKView) {
		// Set the overall physicsWorld and outer wall characteristics
		physicsWorld.contactDelegate = self
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

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		// Go though all touch points in the set
		for touch in (touches) {
			let location = touch.location(in: self)

			// If it's not already a ball, drop a new ball at that location
			self.addChild(Ball(location: location, ballType: activeBall, bouncyness: CGFloat(bouncyness)))

			if touch.tapCount == 2 {
				self.stopBalls()
			}
		}
	}

	// MARK: - Detect Collisions and Handle
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
//			print("Ball and wall collide")
		}
	}

	// Stop all balls from moving
	func stopBalls() {
		self.enumerateChildNodes(withName: "ball") {
			node, stop in
			node.speed = 0
		}
	}

	// Use to remove any balls that have fallen off the screen
	override func update(_ ntTime: CFTimeInterval) {
	}

	// Loop through all ballNodes, and execute the passed in block if they've falled more than 500 points below the screen, they aren't coming back.
	override func didSimulatePhysics() {
		self.enumerateChildNodes(withName: "ball") {
			node, stop in
			if node.position.y < -500 {
				node.removeFromParent()
			}
		}
	}

	//MARK: - Settings for the Physics World

	// This is the main method to update the physics for the scene based on the settings the user has entered on the Settings View.
	func updateWorldPhysicsSettings() {

		print ("Pre-Update:")
		self.printSceneSettings()

		// Grab the standard user defaults handle
		let userDefaults = UserDefaults.standard

		// Pull values for the different settings. Substitute in defaults if the NSUserDefaults doesn't include any value
		currentGravity       = userDefaults.value(forKey: "gravityValue")         != nil ? abs(userDefaults.value(forKey: "gravityValue")  as! Float) : 9.8
		activeBall           = userDefaults.value(forKey: "activeBall")           != nil ? userDefaults.value(forKey: "activeBall")           as! Int    : 2000
		bouncyness           = userDefaults.value(forKey: "bouncyness")           != nil ? userDefaults.value(forKey: "bouncyness")           as! Float  : 0.5
		boundingWall         = userDefaults.value(forKey: "boundingWallSetting")  != nil ? userDefaults.value(forKey: "boundingWallSetting")  as! Bool   : false
		accelerometerSetting = userDefaults.value(forKey: "accelerometerSetting") != nil ? userDefaults.value(forKey: "accelerometerSetting") as! Bool   : false

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
		self.enumerateChildNodes(withName: "ball") {
			node, stop in
			node.physicsBody?.restitution = CGFloat(self.bouncyness)
		}

		// Set whether there is a bounding wall (edge loop) around the frame
		if boundingWall == true {
			self.physicsBody = SKPhysicsBody(edgeLoopFrom: ScreenRect)
		} else {
			self.physicsBody = nil
		}

		print ("Post-Update:")
		self.printSceneSettings()

	}

	//MARK: - Accelerate Framework Methods

	// If the user selects to have the accelerometer active, complex gravity must be calculated whenever the Core Motion delegate is called
	func startComplexGravity() {

		// Check if the accelerometer is available
		if (motionManager.isAccelerometerAvailable) {
			motionManager.startAccelerometerUpdates(to: OperationQueue()) {
				(data, error) in

				// Take the x and y acceleration vectors and multiply by the gravity values to come up with a full gravity vector
				let xGravity = CGFloat((data?.acceleration.x)!) * CGFloat(self.currentGravity)
				let yGravity = CGFloat(data!.acceleration.y) * CGFloat(self.currentGravity)
				self.physicsWorld.gravity = CGVector(dx: yGravity, dy: -xGravity)
			}
		}
	}

	// Print out the current Physics World Settings
	func printSceneSettings() {
		print ("Gravity: \(currentGravity ?? 0)")
		print ("Active Ball: \(activeBall ?? 0)")
		print ("Bouncyness:  \(bouncyness ?? 0)")

		print ("Bounding Wall: \(boundingWall != nil ? boundingWall ? "ON" : "OFF" : "OFF")")
		print ("Accelerometer: \(accelerometerSetting != nil ? boundingWall ? "ON" : "OFF" : "OFF")")
	}
}
