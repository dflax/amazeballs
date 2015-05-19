//
//  ABBallScene.m
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


#import "ABBallScene.h"
#import <CoreMotion/CoreMotion.h>
#import "ABBall.h"
#import "ABWall.h"

// Set up a private property to determine whether the scene's contents have been created yet
@interface ABBallScene()
@property BOOL contentCreated;
@property CGFloat currentGravity;
@property int activeBall;
@property CGFloat bouncyness;
@end

@implementation ABBallScene

// When the scene is moved into view, if content isn't alredy loaded, load it
- (void)didMoveToView:(SKView *)view {
	if (!self.contentCreated) {
		[self createSceneContents];
		self.contentCreated = YES;
	}
}

// Configure the base contents for the scene - if it's the first load
- (void)createSceneContents {

	// Set the background Brick Wall image via a SpriteNode
	NSString * backgroundImageName;

	// If this is an iPad, use the iPad art, if it's not, check the screen size and select
	// the appropriate sized image - from the Image Assets
	CGRect screenSize = [[UIScreen mainScreen] bounds];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		backgroundImageName = @"brickwall_ipad";
	} else {
		if (screenSize.size.height > 500.0) {
			backgroundImageName = @"brickwall_iphone4";
		} else {
			backgroundImageName = @"brickwall_iphone35";
		}
	}

	// Load the background brickwall image as a SpriteNode and add it as a child
	SKSpriteNode * backgroundWallNode = [[SKSpriteNode alloc] initWithImageNamed:backgroundImageName];
	CGRect fullScreen = [[UIScreen mainScreen] bounds];

	// Transform from the different coordinate systems appropriately
	backgroundWallNode.position = CGPointMake(fullScreen.size.height / 2.0, fullScreen.size.width /2.0);
	[self addChild:backgroundWallNode];

	// Set the SpriteKit scale mode
	self.scaleMode = SKSceneScaleModeAspectFit;

	// Update the physics for the world
	[self updateWorldPhysicsSettings];

	// Set the contact delegate to self
	self.physicsWorld.contactDelegate = self;

	// Load the wall on the bottom of the scene
	ABWall * bottomWall = [ABWall newWall];
	[self addChild:bottomWall];
}

// When the user touches the screen, determine if they are touching free space
// if free space, drop in a new ball. If already touching a ball, do nothing
// and allow the ABBall class to handle the touch.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

	// Go though all touch points in the set
	for (UITouch * aTouch in touches) {

		// Determine what node is at the point of the touch
		CGPoint location = [aTouch locationInNode:self];
		CGPoint viewLocation = [aTouch locationInView:self.view];
		SKNode *    node = [self nodeAtPoint:location];

		// If it's not already a ball, drop a new ball at that location
		if (![node.name isEqualToString:@"ballNode"]) {
			[self addChild:[ABBall newBallNodeAtLocation:viewLocation ofType:_activeBall withBouncyness:_bouncyness]];
		}
	}
}

// Leverage the SpriteKit rendering loop to trigger clean up
// Check if any of the balls have fallen off the scren and out of range, if so,
// remove them from the world
- (void)didSimulatePhysics {

	// Loop through all ballNodes, and execute the passed in block
	// if they've falled more than 500 points below the screen, they aren't
	// coming back.
	[self enumerateChildNodesWithName:@"ballNode" usingBlock:^(SKNode *node, BOOL *stop) {
		if (node.position.y < -500) {
			[node removeFromParent];
		}
	}];
}

#pragma mark - Settings for the Physics World

// This is the main method to update the physics for the scene based on the
// settings the user has entered on the Settings View.
- (void)updateWorldPhysicsSettings {

	// Grab the standard user defaults handle
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];

	// Pull values for the different settings. Substitute in defaults if the NSUserDefaults doesn't include any value
	          _currentGravity = [userDefaults floatForKey:@"gravityValue"]        ? [userDefaults floatForKey:@"gravityValue"]        : -9.8;
	              _activeBall = [userDefaults integerForKey:@"activeBall"]        ? [userDefaults integerForKey:@"activeBall"]        : 2000;
	              _bouncyness = [userDefaults floatForKey:@"bouncyness"]          ? [userDefaults floatForKey:@"bouncyness"]          : 0.5;
	BOOL         boundingWall = [userDefaults boolForKey:@"boundingWallSetting"]  ? [userDefaults boolForKey:@"boundingWallSetting"]  : NO;
	BOOL accelerometerSetting = [userDefaults boolForKey:@"accelerometerSetting"] ? [userDefaults boolForKey:@"accelerometerSetting"] : NO;

	// If no Accelerometer, set the simple gravity for the world
	if (!accelerometerSetting) {
		self.physicsWorld.gravity = CGVectorMake(0.0, _currentGravity);

		// In case it's on, turn off the accelerometer
		[self.motionManager stopAccelerometerUpdates];
	} else {

		// Turn on the accelerometer to handle setting the gravity
		[self startComplexGravity];
	}

	// Loop through all balls and update their bouncyness values
	[self enumerateChildNodesWithName:@"ballNode" usingBlock:^(SKNode *node, BOOL *stop) {
		node.physicsBody.restitution = _bouncyness;
	}];

	// Set whether there is a bounding wall (edge loop) around the frame
	if (boundingWall) {
		CGSize boundrySize = CGSizeMake(MAX(self.view.frame.size.height, self.view.frame.size.width), MIN(self.view.frame.size.height, self.view.frame.size.width));
		CGRect boundryRect = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, boundrySize.width, boundrySize.height);
		self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:boundryRect];
	} else {
		self.physicsBody = nil;
	}
}

#pragma mark - Accelerate Framework Methods

// Get the Motion Manager - to be used for the Complex Gravity (aka accelerometer)
- (CMMotionManager *)motionManager {
	CMMotionManager * motionManager = nil;
	id appDelegate = [UIApplication sharedApplication].delegate;
	if ([appDelegate respondsToSelector:@selector(motionManager)]) {
		motionManager = [appDelegate motionManager];
	}
	return motionManager;
}

// If the user selects to have the accelerometer active, complex gravity must be
// calculated whenever the Core Motion delegate is called
- (void)startComplexGravity {

	// Talk to the motion manager and give it a block to run whenever there's
	// an update (the block runs on a background thread)
	[self.motionManager
	 startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
	 withHandler:^(CMAccelerometerData * data, NSError *error) {
		 dispatch_async(dispatch_get_main_queue(), ^{

			 // Take the x and y acceleration vectors and multiply by the gravity values to come up with a full gravity vector
			 CGFloat xGravity = (data.acceleration.x) * _currentGravity;
			 CGFloat yGravity = (data.acceleration.y) * -_currentGravity;
			 self.physicsWorld.gravity = CGVectorMake(yGravity, xGravity);
		 });
	 }
	 ];
}

#pragma mark - Handle Contact Between Nodes
- (void)didBeginContact:(SKPhysicsContact *)contact {
/*
	// Determine what's hitting what? This doens't do anything other than detect the collision
    SKNode * nodeA = contact.bodyA.node;
    SKNode * nodeB = contact.bodyB.node;
    if ([nodeA isKindOfClass:[ABBall class]]) {
		NSLog(@"bodyA is a ball");
    }
    if ([nodeB isKindOfClass:[ABBall class]]) {
		NSLog(@"bodyB is a ball");
    }
*/
}

@end
