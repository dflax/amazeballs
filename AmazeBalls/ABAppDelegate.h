//
//  ABAppDelegate.h
//  AmazeBalls
//
//  Created by Daniel Flax on 6/15/13.
//  Copyright (c) 2013 Piece of Cake Adventures, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface ABAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// To track the accelerometer, a Core Motion Manager is necessary
// this will provide a single instance for the app to use throughout all objects.
@property (readonly) CMMotionManager * motionManager;

@end
