//
//  ABViewController.m
//  AmazeBalls
//
//  Created by Daniel Flax on 6/15/13.
//  Copyright (c) 2013 Piece of Cake Adventures, LLC. All rights reserved.
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
	
	// Set the debugging settings
	ballView.showsNodeCount = YES;
	ballView.showsDrawCount = YES;
	ballView.showsFPS       = YES;
	
	// Calculate the size for the view - need to use the MIN/MAX technique to ensure a landscape view is created
	CGSize boundrySize = CGSizeMake(MAX(ballView.frame.size.height, ballView.frame.size.width), MIN(ballView.frame.size.height, ballView.frame.size.width));
	
	// Configure the view's frame to use this new size
	self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, boundrySize.width, boundrySize.height);
	
	// Create the scene at the right size and present it
	ballScene = [[ABBallScene alloc] initWithSize:boundrySize];
	[ballView presentScene:ballScene];
}
- (void)viewWillAppear:(BOOL)animated {
	// Whenever the view is going to appear (initially or after changing settings), refresh the phyiscs settings
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

#pragma mark - Don't Rotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - ABSettingsDelegate
- (void)ABSettingsViewController:(ABSettingsViewController *)settingsViewController didCancelSettings:(BOOL)cancelled {
	// If the user cancels the settings view, simply dismiss the modal view controller for settings
	[self dismissViewControllerAnimated:YES completion:nil];
}
- (void)ABSettingsViewController:(ABSettingsViewController *)settingsViewController didSaveGravity:(CGFloat)gravitySetting andBouncyness:(CGFloat)bouncySetting andBoundingWall:(BOOL)boundingWallSetting andAccelerometer:(BOOL)accelerometerSetting andActiveBall:(int)activeBall{
	// When the user taps save, the delegate will call this method, sending back all of the data values from the settings panel
	
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
