//
//  ABSettingsViewController.m
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


#import "ABSettingsViewController.h"
#import "ABViewController.h"

@interface ABSettingsViewController ()
@property int activeBall;
@end

@implementation ABSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

// When loading the view, retrieve the prevously set values for the settings
// and update the switches and sliders accordingly
- (void)viewDidLoad {
	[super viewDidLoad];

	// Set the initial state for the view's value controls
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];

	_gravitySlider.value    = [userDefaults floatForKey:@"gravityValue"]        ? [userDefaults floatForKey:@"gravityValue"] / -40.0 : -9.8 / -40.0;
	_bouncynessSlider.value = [userDefaults floatForKey:@"bouncyness"]          ? [userDefaults floatForKey:@"bouncyness"]           :  0.5;
	_boundingSwitch.on      = [userDefaults boolForKey:@"boundingWallSetting"]  ? [userDefaults boolForKey:@"boundingWallSetting"]   :  NO;
	_accelerometerSwitch.on = [userDefaults boolForKey:@"accelerometerSetting"] ? [userDefaults boolForKey:@"accelerometerSetting"]  :  NO;
	_activeBall             = [userDefaults integerForKey:@"activeBall"]        ? [userDefaults integerForKey:@"activeBall"]         :  2000;

	// Visually show which ball is currently active
	UIButton * currentBall = (UIButton *)[self.view viewWithTag:_activeBall];
	currentBall.layer.borderColor = [[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] CGColor];
	currentBall.layer.borderWidth = 1.0;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

// If the user taps cancel, call the delegate method to cancel (dismissing the settings view controller)
- (IBAction)cancelSettingsView:(id)sender {
	[_delegate ABSettingsViewController:self didCancelSettings:YES];
}

// If the user taps save, call the delegate method to save - with all of the widget values
- (IBAction)saveSettings:(id)sender {
	[_delegate ABSettingsViewController:self
						 didSaveGravity:_gravitySlider.value
						  andBouncyness:_bouncynessSlider.value
						andBoundingWall:_boundingSwitch.on
					   andAccelerometer:_accelerometerSwitch.on
						  andActiveBall:_activeBall];
}

// When user taps on a ball type, clear all selections and update UI to demonstrate which one's been
// selected, also update the _activeBall value.
- (IBAction)selectBallType:(id)sender {
	_buttonAmazeBall.layer.borderWidth     = 0.0;
	_buttonBaseball.layer.borderWidth      = 0.0;
	_buttonBasketball.layer.borderWidth    = 0.0;
	_buttonFootball.layer.borderWidth      = 0.0;
	_buttonPumpkin.layer.borderWidth       = 0.0;
	_buttonSoccerBallOne.layer.borderWidth = 0.0;
	_buttonSoccerBallTwo.layer.borderWidth = 0.0;
	_buttonRandom.layer.borderWidth        = 0.0;

	UIButton * senderButton = (UIButton *)sender;

	senderButton.layer.borderColor = [[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] CGColor];
	senderButton.layer.borderWidth = 1.0;

	_activeBall = senderButton.tag;
}


@end
