//
//  ABBall.m
//  AmazeBalls
//
//  Created by Daniel Flax on 6/15/13.
//  Copyright (c) 2013 Piece of Cake Adventures, LLC. All rights reserved.
//
//
// The MIT License (MIT)
//
// Copyright (c) 2013 Daniel Flax
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//


#import "ABBall.h"
#import "ABBallScene.h"

@implementation ABBall

// Create and return a new ball at the specified location of the type passed in
+ (instancetype)newBallNodeAtLocation:(CGPoint)location ofType:(int)ballType withBouncyness:(CGFloat)bouncyness {
	// Deal with the coordinate system transformations
	CGFloat offset;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		offset = 768.0;
	} else {
		offset = 320.0;
	}

	// Based on the requested ball type, select the right string to load the image
	NSString * ballNameString;
	if (ballType == 2007) {
		ballType = (arc4random() % 7) + 2000;
	}
	switch (ballType) {
		case 2000:
			ballNameString = @"amazeball";
			break;
		case 2001:
			ballNameString = @"baseball";
			break;
		case 2002:
			ballNameString = @"basketball";
			break;
		case 2003:
			ballNameString = @"football";
			break;
		case 2004:
			ballNameString = @"pumpkin";
			break;
		case 2005:
			ballNameString = @"soccer1";
			break;
		case 2006:
			ballNameString = @"soccer2";
			break;
		default:
			break;
	}

	// Calculate the correct coordinates to put the new ball - in the Scene's coordinate system
	CGPoint skLocation = CGPointMake(location.x, offset - (location.y - 12.5));

	// Create the actual ball node object and set the appropriate settings for the node
	ABBall * newBall = [[ABBall alloc] initWithImageNamed:ballNameString];
	newBall.position = skLocation;
	newBall.name = @"ballNode";
	newBall.userInteractionEnabled = YES;

	// Add the properties for the ball's physics body - with the bouncyness that's been passed in
	newBall.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:newBall.frame.size.width / 2.0];
	newBall.physicsBody.dynamic = YES;
	newBall.physicsBody.affectedByGravity = YES;
	newBall.physicsBody.allowsRotation = YES;
	newBall.physicsBody.restitution = bouncyness;

	// Set the category bit masks for collision, etc.
	newBall.physicsBody.categoryBitMask    = ballCategory;
	newBall.physicsBody.collisionBitMask   = ballCategory | wallCategory | edgeCategory;
	newBall.physicsBody.contactTestBitMask = ballCategory | wallCategory | edgeCategory;

	return newBall;
}

// When touches begin, figure out where in the parent view, the ball is, and move to the new location
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch * touch = [touches anyObject];
	SKScene * parentNode = (SKScene *)self.parent;
	CGPoint viewLocation = [touch locationInView:parentNode.view];

	CGPoint translatedPoint = CGPointMake(viewLocation.x, 320.0 - viewLocation.y);

	self.position = translatedPoint;
}

// As touches continue, move the ball to the new location - with an offset for the positon
// of the finger relative to the position of the ball's center
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *      touch = [touches anyObject];
	SKScene * parentNode = (SKScene *)self.parent;
	CGPoint viewLocation = [touch locationInView:parentNode.view];

	CGSize mySize = self.scene.size;
	CGPoint translatedPoint = CGPointMake(viewLocation.x, mySize.height - viewLocation.y);

	self.position = translatedPoint;
}

// When touches end, impart an impulse vector in the direction of the last touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	// trial and error... selected 14.0 to be the momentum. Have fun with it.
	CGFloat            momentum = 14.0;
	UITouch *         lastTouch = [touches anyObject];
	SKScene *       parentScene = (SKScene *)self.parent;
	CGPoint   lastTouchLocation = [lastTouch locationInView:parentScene.view];
	CGPoint penultimateLocation = [lastTouch previousLocationInView:parentScene.view];

	CGVector movementVector = CGVectorMake((momentum * (lastTouchLocation.x - penultimateLocation.x)),
										   (momentum * -(lastTouchLocation.y - penultimateLocation.y)));

	[self.physicsBody applyImpulse:movementVector];
}

@end
