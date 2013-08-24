//
//  ABAppDelegate.m
//  AmazeBalls
//
//  Created by Daniel Flax on 6/15/13.
//  Copyright (c) 2013 Piece of Cake Adventures, LLC. All rights reserved.
//

#import "ABAppDelegate.h"

@implementation ABAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	// Instantiate the instance of the Core Motion Manager for the whole app to use
	_motionManager = [[CMMotionManager alloc] init];

	return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
}
- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
