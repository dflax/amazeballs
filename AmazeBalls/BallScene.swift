//
//  BallScene.swift
//  AmazeBalls
//
//  Created by Daniel Flax on 5/19/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

import UIKit
import SpriteKit

class BallScene: SKScene, SKPhysicsContactDelegate {

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder) is not used in this app")
	}

	override init(size: CGSize) {
		super.init(size: size)
	}

	override func didMoveToView(view: SKView) {

		// Set the overall physicsWorld and outer wall characteristics
		physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
		physicsWorld.contactDelegate = self
		physicsBody = SKPhysicsBody(edgeLoopFromRect: ScreenRect)
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
println("floor: \(floor)")
	}

	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {

		for touch in (touches as! Set<UITouch>) {
			let location = touch.locationInNode(self)
			// TODO DROP BALLS HERE
			println("Drop ball in at \(location)")
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
			println("Ball and Floor collided")
		}

		// Checck if the collision is between Ball and Floor
		if ((firstBody.categoryBitMask & CollisionCategories.Ball != 0) && (secondBody.categoryBitMask & CollisionCategories.EdgeBody != 0)) {
			println("Ball and wall collide")
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

}

