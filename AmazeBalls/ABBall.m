//
//  ABBall.m
//  AmazeBalls
//
//  Created by Daniel Flax on 6/15/13.
//  Copyright (c) 2013 Piece of Cake Adventures, LLC. All rights reserved.
//

#import "ABBall.h"
#import "ABBallScene.h"

@implementation ABBall

// Create and return a new ball at the specified location
+ (instancetype)newBallNodeAtLocation:(CGPoint)location {
	// Deal with the coordinate system transformations
	CGFloat offset;
	if ([ABBall isPad]) {
		offset = 768.0;
	} else {
		offset = 320.0;
	}

	// Determine which ball to load
	NSString * ballNameString;
	int activeBall = [[NSUserDefaults standardUserDefaults] integerForKey:@"activeBall"] ? [[NSUserDefaults standardUserDefaults] integerForKey:@"activeBall"] : 2000;
	if (activeBall == 2007) {
		activeBall = (arc4random() % 7) + 2000;
	}
	switch (activeBall) {
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
	// Calculate where to put the new ball, create it with the ball.png image, put it in place and set the name
	CGPoint skLocation = CGPointMake(location.x, offset - (location.y - 12.5));
	ABBall * coloredBall = [[ABBall alloc] initWithImageNamed:ballNameString];
	coloredBall.position = skLocation;
	coloredBall.name = @"ballNode";
	coloredBall.userInteractionEnabled = YES;

	// Add the properties for the ball's physics body
	coloredBall.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:coloredBall.frame.size.width / 2.0];
	coloredBall.physicsBody.dynamic = YES;
	coloredBall.physicsBody.affectedByGravity = YES;
	coloredBall.physicsBody.allowsRotation = YES;
	coloredBall.physicsBody.restitution = 1;

	// Set the category bit masks for collision, etc.
	coloredBall.physicsBody.categoryBitMask    = ballCategory;
	coloredBall.physicsBody.collisionBitMask   = ballCategory | wallCategory | edgeCategory;
	coloredBall.physicsBody.contactTestBitMask = ballCategory | wallCategory | edgeCategory;

	return coloredBall;
}

// When touches begin, figure out where in the parent view, the ball is, and move to the new location
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch * touch = [touches anyObject];
	SKScene * parentNode = (SKScene *)self.parent;
	CGPoint viewLocation = [touch locationInView:parentNode.view];

	CGPoint translatedPoint = CGPointMake(viewLocation.x, 320.0 - viewLocation.y);

	self.position = translatedPoint;
}

// As touches continue, move the ball to the new location - with an offset for the positon of the finger relative to the position of the ball's center
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
	CGFloat            momentum = 14.0;
	UITouch *         lastTouch = [touches anyObject];
	SKScene *       parentScene = (SKScene *)self.parent;
	CGPoint   lastTouchLocation = [lastTouch locationInView:parentScene.view];
	CGPoint penultimateLocation = [lastTouch previousLocationInView:parentScene.view];

	CGVector movementVector = CGVectorMake((momentum * (lastTouchLocation.x - penultimateLocation.x)), (momentum * -(lastTouchLocation.y - penultimateLocation.y)));

	[self.physicsBody applyImpulse:movementVector];
}

// Utility method to tell whether you're working on an iPad or not
+ (BOOL)isPad {
#ifdef UI_USER_INTERFACE_IDIOM
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
#endif
	return NO;
}


@end
