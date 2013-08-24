//
//  ABBallScene.m
//  AmazeBalls
//
//  Created by Daniel Flax on 6/15/13.
//  Copyright (c) 2013 Piece of Cake Adventures, LLC. All rights reserved.
//

#import "ABBallScene.h"
#import <CoreMotion/CoreMotion.h>
#import "ABBall.h"
#import "ABWall.h"

// Set up a private property to determine whether the scene's contents have been created yet
@interface ABBallScene()
@property BOOL contentCreated;
@end

@implementation ABBallScene

// When the scene is moved into view, if content isn't alredy loaded, load it
- (void)didMoveToView:(SKView *)view {
	if (!self.contentCreated) {
		[self createSceneContents];
		self.contentCreated = YES;
	}
}

// Configure the base contents for the scene
- (void)createSceneContents {
	// Set the background color and scale mode for the scene
	self.backgroundColor = [SKColor blueColor];
	self.scaleMode = SKSceneScaleModeAspectFit;

	// Update the physics for the world
	[self updateWorldPhysicsSettings];

	// Set the contact delegate to self
	self.physicsWorld.contactDelegate = self;

	// Load the wall on the bottom of the scene
	ABWall * bottomWall = [ABWall newWallAtLocation:3 withRotation:0.0];
	[self addChild:bottomWall];
}

// When the user touches the screen, determine whether it's a ball being touched and move it, otherwise, drop a new ball
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch * aTouch in touches) {
		CGPoint location = [aTouch locationInNode:self];
		CGPoint viewLocation = [aTouch locationInView:self.view];
		SKNode *    node = [self nodeAtPoint:location];

		// If it's not on a ball, drop a new ball
		if (![node.name isEqualToString:@"ballNode"]) {
			[self addChild:[ABBall newBallNodeAtLocation:viewLocation]];
		}
	}
}

// Check if any of the balls have fallen off the scren and out of range, if so, remove them from the world
- (void)didSimulatePhysics {
	[self enumerateChildNodesWithName:@"ballNode" usingBlock:^(SKNode *node, BOOL *stop) {
		if (node.position.y < -500) {
			[node removeFromParent];
		}
	}];
}

#pragma mark - Settings for the Physics World
// Update the physics for the scene based on the settings the user has set
- (void)updateWorldPhysicsSettings {

	// Grab the standard user defaults handle
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];

	// Pull values for a variety of possible settings
	CGFloat      gravityValue = [userDefaults floatForKey:@"gravityValue"]         ? [userDefaults floatForKey:@"gravityValue"]         : -9.8;
	CGFloat        bouncyness = [userDefaults floatForKey:@"bouncyness"]           ? [userDefaults floatForKey:@"bouncyness"]           : 0.5;
	BOOL         boundingWall = [userDefaults boolForKey:@"boundingWallSetting"]   ? [userDefaults boolForKey:@"boundingWallSetting"]   : NO;
	BOOL accelerometerSetting = [userDefaults boolForKey:@"accelerometerSetting"]  ? [userDefaults boolForKey:@"accelerometerSetting"]  : NO;

	// If no Accelerometer, set the simple gravity for the world
	if (!accelerometerSetting) {
		self.physicsWorld.gravity = CGPointMake(0.0, gravityValue);

		// In case it's on, turn off the accelerometer
		[self.motionManager stopAccelerometerUpdates];
	} else {
		// Turn on the accelerometer to handle setting the gravity
		[self startComplexGravity];
	}

	// Loop through all balls and set the bouncyness values
	[self enumerateChildNodesWithName:@"ballNode" usingBlock:^(SKNode *node, BOOL *stop) {
		node.physicsBody.restitution = bouncyness;
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

// Get the Motion Manager
- (CMMotionManager *)motionManager {
	CMMotionManager * motionManager = nil;
	id appDelegate = [UIApplication sharedApplication].delegate;
	if ([appDelegate respondsToSelector:@selector(motionManager)]) {
		motionManager = [appDelegate motionManager];
	}
	return motionManager;
}

// If the user selects to have the accelerometer active, complex gravity must be calculated whenever the Core Motion delegate is called
- (void)startComplexGravity {
	// Grab a handle for the NSUserDefaults
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];

	// Figure out what factor for gravity should be used. If nothing's been set, use standard Earth g, otherwise, use what the user has set with the Settings slider
	CGFloat gravityValue = [userDefaults floatForKey:@"gravityValue"] ? [userDefaults floatForKey:@"gravityValue"] : -9.8;

	// Talk to the motion manager and give it a block to run whenever there's an update (the block runs on a background thread)
	[self.motionManager
	 startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
	 withHandler:^(CMAccelerometerData * data, NSError *error) {
		 dispatch_async(dispatch_get_main_queue(), ^{

			 // Take the x and y acceleration vectors and multiply by the gravity values to come up with a full gravity vector
			 CGFloat xGravity = (data.acceleration.x) * gravityValue;
			 CGFloat yGravity = (data.acceleration.y) * -gravityValue;
			 self.physicsWorld.gravity = CGPointMake(yGravity, xGravity);
		 });
	 }
	 ];
}


#pragma mark - Handle Contact Between Nodes
- (void)didBeginContact:(SKPhysicsContact *)contact {
/*	NSLog(@"Contact detected");

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
