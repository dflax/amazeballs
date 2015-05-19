//
//  GameViewController.swift
//  Amazeballs
//
//  Created by Daniel Flax on 5/19/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//
/*
import UIKit
import SpriteKit

class GameViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		let skView = self.view as! SKView

		skView.showsFPS = true
		skView.showsNodeCount = true

		let scene = GameScene(size: skView.bounds.size)
		scene.scaleMode = .AspectFit

		skView.presentScene(scene)
	}

	override func shouldAutorotate() -> Bool {
		return true
	}

	override func supportedInterfaceOrientations() -> Int {
		if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
			return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
		} else {
			return Int(UIInterfaceOrientationMask.All.rawValue)
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()

	}

	override func prefersStatusBarHidden() -> Bool {
		return true
	}

}
*/
import UIKit
import SpriteKit

class GameViewController: UIViewController, SettingsDelegateProtocol {

	override func viewDidLoad() {
		super.viewDidLoad()

		let skView = self.view as! SKView

		let scene = GameScene(size: skView.bounds.size)
		scene.scaleMode = .AspectFit

		skView.presentScene(scene)
		skView.showsFPS = true
		skView.showsNodeCount = true
		skView.ignoresSiblingOrder = true
		scene.scaleMode = .ResizeFill
		
		// Present the main scene for the game
		skView.presentScene(scene)
		
		// Calculate the size for the view
		// Use the MIN/MAX to ensure a landscape view is created
		//		CGSize boundrySize = CGSizeMake(MAX(ballView.frame.size.height, ballView.frame.size.width), MIN(ballView.frame.size.height, ballView.frame.size.width));
		
		// Set the view's frame to use this new size
		//		self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, boundrySize.width, boundrySize.height);
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	// Update the physics settings, when the view appears - after Settings are changed
	override func viewWillAppear(animated: Bool) {
		// self.scene.updateWorldPhysicsSettings()
	}

	// Prepare for segues
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

		// Leveraging a Storyboard segue to bring up the settings view, must set the delegate correctly
		if (segue.identifier == "settingsSegue") {
println("settingsSegue triggered")

			// set the destination of the segue (the settingsView) delegate to myself
			let settingsView = segue.destinationViewController as! SettingsViewController
			settingsView.delegate = self
		}
	}
	
	//MARK: - Settings Delegate Protocol Methods

	// When the user taps save, the delegate calls this method, sending back all of the data values from the settings panel
	func settingsViewController(viewController: SettingsViewController, gravitySetting: CGFloat, bouncySetting: CGFloat, boundingWallSetting: Bool, accelerometerSetting: Bool, activeBall: Int) {
		println("Save content")

		// Ceate a handle for the Standard User Defaults
		let userDefaults = NSUserDefaults.standardUserDefaults()

		let cgFloatGrav = gravitySetting * -40.0
		let cgFloatBounce =
		// Store values for the various settings in User Defaults
		userDefaults.setFloat(cgFloatGrav.f, forKey:"gravityValue")
		userDefaults.setFloat(bouncySetting.f forKey:"bouncyness")
		userDefaults.setBool(boundingWallSetting forKey:"boundingWallSetting")
		userDefaults.setBool(accelerometerSetting forKey:"accelerometerSetting")
		userDefaults.setInteger(activeBall forKey:"activeBall")
		
		// With the new physics now stored in NSUserDefaults, update the Physics for the scene
		[ballScene updateWorldPhysicsSettings];
		
		// Now dismiss the modal view controller
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	// If the user cancels the settings view, simply dismiss the modal view controller for settings
	func settingsViewController(viewController: SettingsViewController, cancelled: Bool) {
		println("Cancelled")
		self.dismissViewControllerAnimated(true, completion: nil)
	}

}


/*

- (void)ABSettingsViewController:(ABSettingsViewController *)settingsViewController didSaveGravity:(CGFloat)gravitySetting andBouncyness:(CGFloat)bouncySetting andBoundingWall:(BOOL)boundingWallSetting andAccelerometer:(BOOL)accelerometerSetting andActiveBall:(int)activeBall{

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

*/

