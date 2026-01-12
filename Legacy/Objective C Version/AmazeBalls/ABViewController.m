//
//  ABViewController.m
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


#import "ABViewController.h"
#import <SpriteKit/SpriteKit.h>

@interface ABViewController ()
@end

@implementation ABViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	// Load the view and cast it as an SKView
	SKView * ballView = (SKView *)self.view;

	// Set the debugging settings - useful when developing, turned off for release.
	ballView.showsNodeCount = NO;
	ballView.showsDrawCount = NO;
	ballView.showsFPS       = NO;

	// Calculate the size for the view
	// Use the MIN/MAX to ensure a landscape view is created
	CGSize boundrySize = CGSizeMake(MAX(ballView.frame.size.height, ballView.frame.size.width), MIN(ballView.frame.size.height, ballView.frame.size.width));

	// Set the view's frame to use this new size
	self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, boundrySize.width, boundrySize.height);

	// Create the scene at the right size and present it
	ballScene = [[ABBallScene alloc] initWithSize:boundrySize];
	[ballView presentScene:ballScene];
}

- (void)viewWillAppear:(BOOL)animated {
	// Whenever the view is going to appear (initially or after settings), refresh the phyiscs settings
	[ballScene updateWorldPhysicsSettings];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

	// Leveraging a Storyboard segue to bring up the settings view, must set the delegate correctly
	if ([segue.identifier isEqualToString:@"settingsSegue"]) {
		ABSettingsViewController * settingsView = segue.destinationViewController;
		settingsView.delegate = self;
	}
}

#pragma mark - Disable rotation. This is a portrait app
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - ABSettingsDelegate methods
- (void)ABSettingsViewController:(ABSettingsViewController *)settingsViewController didCancelSettings:(BOOL)cancelled {
	// If the user cancels the settings view, simply dismiss the modal view controller for settings
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)ABSettingsViewController:(ABSettingsViewController *)settingsViewController didSaveGravity:(CGFloat)gravitySetting andBouncyness:(CGFloat)bouncySetting andBoundingWall:(BOOL)boundingWallSetting andAccelerometer:(BOOL)accelerometerSetting andActiveBall:(int)activeBall{
	// When the user taps save, the delegate calls this method, sending back all of the data values from the settings panel

	// Ceate a handle for the Standard User Defaults
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];

	// Store values for the various settings in User Defaults
	[userDefaults setFloat:gravitySetting * -40.0 forKey:@"gravityValue"];
	[userDefaults setFloat:bouncySetting forKey:@"bouncyness"];
	[userDefaults setBool:boundingWallSetting forKey:@"boundingWallSetting" ];
	[userDefaults setBool:accelerometerSetting forKey:@"accelerometerSetting"];
	[userDefaults setInteger:activeBall forKey:@"activeBall"];

	// With the new physics now stored in NSUserDefaults, update the Physics for the scene
	[ballScene updateWorldPhysicsSettings];

	// Now dismiss the modal view controller
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
