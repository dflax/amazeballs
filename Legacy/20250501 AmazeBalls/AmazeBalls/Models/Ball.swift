//
//  Ball.swift
//  amazeballs
//
//  Created by Daniel Flax on 3/28/20.
//  Copyright © 2020 Daniel Flax. All rights reserved.
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
		let emptyTexture = SKTexture(imageNamed: "ball-amazeball")
		super.init(texture: emptyTexture, color: SKColor.clear, size: emptyTexture.size())
	}

	init(location: CGPoint, ballType: Int, bouncyness: CGFloat) {

		let emptyTexture = SKTexture(imageNamed: "ball-amazeball")
		super.init(texture: emptyTexture, color: SKColor.clear, size: emptyTexture.size())

		var ballNameString = ""
		var ballLookup = ballType

		// If a random ball is selected, select the random ball from the first 7 of the options
		//
		// Peformance problems with the new, more complicated shapes. Need to figure out how to
		// speed up performance. Most likely using the SKTexture preload technique.
		if (ballLookup == 2007) {
			ballLookup = randomNumber(minX: 2000, maxX: 2006)
		}

		switch (ballLookup) {
		case 2000:
			ballNameString = "ball-amazeball"
			break
		case 2001:
			ballNameString = "ball-baseball1"
			break
		case 2002:
			ballNameString = "ball-basketball1"
			break
		case 2003:
			ballNameString = "ball-football1"
			break
		case 2004:
			ballNameString = "ball-pumpkin1"
			break
		case 2005:
			ballNameString = "ball-soccer1"
			break
		case 2006:
			ballNameString = "ball-soccer2"
			break
		case 2007:
			ballNameString = "ball-apple1"
			break
		case 2008:
			ballNameString = "ball-banana1"
			break
		case 2009:
			ballNameString = "ball-banana2"
			break
		case 2010:
			ballNameString = "ball-banana3"
			break
		case 2011:
			ballNameString = "ball-baseball2"
			break
		case 2012:
			ballNameString = "ball-baseball3"
			break
		case 2013:
			ballNameString = "ball-basketball2"
			break
		case 2014:
			ballNameString = "ball-basketball3"
			break
		case 2015:
			ballNameString = "ball-bowling1"
			break
		case 2016:
			ballNameString = "ball-bowling2"
			break
		case 2017:
			ballNameString = "ball-bowling3"
			break
		case 2018:
			ballNameString = "ball-bowling4"
			break
		case 2019:
			ballNameString = "ball-bowlingpin1"
			break
		case 2020:
			ballNameString = "ball-bowlingpins2"
			break
		case 2021:
			ballNameString = "ball-cherries1"
			break
		case 2022:
			ballNameString = "ball-cherries2"
			break
		case 2023:
			ballNameString = "ball-christmasball1"
			break
		case 2024:
			ballNameString = "ball-cookie1"
			break
		case 2025:
			ballNameString = "ball-discoball1"
			break
		case 2026:
			ballNameString = "ball-discoball2"
			break
		case 2027:
			ballNameString = "ball-egg1"
			break
		case 2028:
			ballNameString = "ball-eightball1"
			break
		case 2029:
			ballNameString = "ball-football2"
			break
		case 2030:
			ballNameString = "ball-football3"
			break
		case 2031:
			ballNameString = "ball-football4"
			break
		case 2032:
			ballNameString = "ball-glassball1"
			break
		case 2033:
			ballNameString = "ball-golf1"
			break
		case 2034:
			ballNameString = "ball-golf2"
			break
		case 2035:
			ballNameString = "ball-golf3"
			break
		case 2036:
			ballNameString = "ball-hockeypuck1"
			break
		case 2037:
			ballNameString = "ball-olive1"
			break
		case 2038:
			ballNameString = "ball-peace1"
			break
		case 2039:
			ballNameString = "ball-peace2"
			break
		case 2040:
			ballNameString = "ball-soccer3"
			break
		case 2041:
			ballNameString = "ball-soccer4"
			break
		case 2042:
			ballNameString = "ball-soccer5"
			break
		case 2043:
			ballNameString = "ball-soccer6"
			break
		case 2044:
			ballNameString = "ball-tennis1"
			break
		case 2045:
			ballNameString = "ball-tennis2"
			break
		case 2046:
			ballNameString = "ball-tennis3"
			break
		case 2047:
			ballNameString = "ball-tennis4"
			break
		case 2048:
			ballNameString = "ball-tennis5"
			break
		case 2049:
			ballNameString = "ball-volleyball1"
			break
		case 2050:
			ballNameString = "ball-volleyball2"
			break
		default:
			break
		}

		let texture = SKTexture(imageNamed: ballNameString)
		self.texture = texture

		size = CGSize(width: 75.0, height: 75.0)
		position = location

		physicsBody = SKPhysicsBody(texture: self.texture!,size:self.size)
//		physicsBody = SKPhysicsBody(circleOfRadius: 75.0, center: location)

		physicsBody?.isDynamic = true
		physicsBody?.usesPreciseCollisionDetection = false
		physicsBody?.allowsRotation = true
		isUserInteractionEnabled = true
		physicsBody?.affectedByGravity = true
		physicsBody?.restitution = bouncyness
		physicsBody?.friction = 0.5
		physicsBody?.linearDamping = 0.0

		physicsBody?.categoryBitMask    = CollisionCategories.Ball
		physicsBody?.contactTestBitMask = CollisionCategories.EdgeBody | CollisionCategories.Ball
	}

	// MARK: - Touch Handling
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let location = touch.location(in: self)

			moveTransalation = CGPoint(x: location.x - self.anchorPoint.x, y: location.y - self.anchorPoint.y)
		}
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//		var nodeTouched = SKNode()
//		var currentNodeTouched = SKNode()

		for touch in touches {
			let location = touch.location(in: self.scene!)
			let previousLocation = touch.previousLocation(in: self.scene!)

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

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//		var nodeTouched = SKNode()

		for touch in (touches as! Set<UITouch>) {
			let location = touch.location(in: self.scene!)
			let previousLocation = touch.previousLocation(in: self.scene!)

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

extension Ball {
	override func copy() -> Any {
		let copy = Ball()

		copy.moveTransalation   = self.moveTransalation
		copy.currentPointVector = self.currentPointVector
		copy.pointVector1       = self.pointVector1
		copy.pointVector2       = self.pointVector2
		copy.pointVector3       = self.pointVector3
		copy.throwVector        = self.throwVector

		copy.texture     = self.texture
		copy.physicsBody = self.physicsBody

		return copy
	}
}
