//
//  Ball.swift
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

class Ball: SKSpriteNode {

	// Displacement between finger touch point and center of clown
	var moveTransalation: CGPoint = CGPoint(x: 0, y: 0)

	// Vectors to track momentum
	var currentPointVector: CGVector = CGVector(dx: 0.0, dy: 0.0)
	var pointVector1: CGVector = CGVector(dx: 0.0, dy: 0.0)
	var pointVector2: CGVector = CGVector(dx: 0.0, dy: 0.0)
	var pointVector3: CGVector = CGVector(dx: 0.0, dy: 0.0)
	var throwVector: CGVector = CGVector(dx: 0.0, dy: 0.0)

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	init() {
		let emptyTexture = SKTexture(imageNamed: "StarterNode")
		super.init(texture: emptyTexture, color: SKColor.clearColor(), size: emptyTexture.size())
	}

	init(location: CGPoint, ballType: Int, bouncyness: CGFloat) {

		let emptyTexture = SKTexture(imageNamed: "StarterNode")
		super.init(texture: emptyTexture, color: SKColor.clearColor(), size: emptyTexture.size())

		var ballNameString = ""
		var ballLookup = ballType

		// If a random ball is selected, select the random ball
		if (ballLookup == 2007) {
			ballLookup = randomNumber(minX: 2000, maxX: 2006)
		}

		switch (ballLookup) {
		case 2000:
			ballNameString = "amazeball"
			break
		case 2001:
			ballNameString = "baseball"
			break
		case 2002:
			ballNameString = "basketball"
			break
		case 2003:
			ballNameString = "football"
			break
		case 2004:
			ballNameString = "pumpkin"
			break
		case 2005:
			ballNameString = "soccer1"
			break
		case 2006:
			ballNameString = "soccer2"
			break
		default:
			break
		}

		let texture = SKTexture(imageNamed: ballNameString)
		self.texture = texture

		size = CGSize(width: 75.0, height: 75.0)
		position = location

		physicsBody = SKPhysicsBody(texture: self.texture,size:self.size)
		physicsBody?.dynamic = true
		physicsBody?.usesPreciseCollisionDetection = false
		physicsBody?.allowsRotation = true
		userInteractionEnabled = true
		physicsBody?.affectedByGravity = true
		physicsBody?.restitution = bouncyness
		physicsBody?.friction = 0.0
		physicsBody?.linearDamping = 0.0
		
		physicsBody?.categoryBitMask    = CollisionCategories.Ball
		physicsBody?.contactTestBitMask = CollisionCategories.EdgeBody | CollisionCategories.Ball
	}

	//MARK: - Touch Handling
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {

		for touch in (touches as! Set<UITouch>) {
			let location = touch.locationInNode(self)

			moveTransalation = CGPoint(x: location.x - self.anchorPoint.x, y: location.y - self.anchorPoint.y)
		}
	}

	override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {

		var nodeTouched = SKNode()
		var currentNodeTouched = SKNode()

		for touch in (touches as! Set<UITouch>) {
			let location = touch.locationInNode(self.scene)
			let previousLocation = touch.previousLocationInNode(self.scene)

			// Calculate an update to the throwing vector
			// Move the last three down the stack
			pointVector3 = pointVector2
			pointVector2 = pointVector1
			pointVector1 = currentPointVector

			// Calculate the current vector
			currentPointVector = CGVector(dx: location.x - previousLocation.x, dy: location.y - previousLocation.y)

			let newPosition = CGPoint(x: location.x + moveTransalation.x, y: location.y + moveTransalation.y)
			self.position = newPosition
		}
	}

	override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
		var nodeTouched = SKNode()

		for touch in (touches as! Set<UITouch>) {
			let location = touch.locationInNode(self.scene)
			let previousLocation = touch.previousLocationInNode(self.scene)

			// Calculate an update to the throwing vector
			// Move the last three down the stack
			pointVector3 = pointVector2
			pointVector2 = pointVector1
			pointVector1 = currentPointVector

			// Calculate the current vector
			currentPointVector = CGVector(dx: location.x - previousLocation.x, dy: location.y - previousLocation.y)

			// Calculate the final throwVector
			throwVector = CGVector(dx: pointVector1.dx + pointVector2.dx + pointVector3.dx + currentPointVector.dx, dy: pointVector1.dy + pointVector2.dy + pointVector3.dy + currentPointVector.dy)

			let momentumVector = CGVector(dx: location.x - previousLocation.x, dy: location.y - previousLocation.y)

			self.physicsBody?.applyImpulse(throwVector)
		}
	}

}


