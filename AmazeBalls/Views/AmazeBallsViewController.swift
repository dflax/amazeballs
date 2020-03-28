//
//  AmazeBallsViewController.swift
//  AmazeBalls
//
//  Created by Daniel Flax on 3/28/20.
//  Copyright © 2020 Daniel Flax. All rights reserved.
//
//                        The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import SpriteKit

class AmazeBallsViewController: UIViewController, SettingsDelegateProtocol {

	var scene: BallScene!

	override func viewDidLoad() {
		super.viewDidLoad()

		let skView = self.view as! SKView

		scene = BallScene(size: skView.bounds.size)
		scene.scaleMode = .aspectFit

		skView.presentScene(scene)
		skView.showsFPS = true
		skView.showsNodeCount = true
		skView.ignoresSiblingOrder = true
		scene.scaleMode = .resizeFill

		// Present the main scene for the game
		skView.presentScene(scene)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// Update the physics settings, when the view appears - after Settings are changed
	override func viewWillAppear(_ animated: Bool) {
		 self.scene.updateWorldPhysicsSettings()
	}

	// Prepare for segues
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Leveraging a Storyboard segue to bring up the settings view, must set the delegate correctly
		if (segue.identifier == "settingsSegue") {

			// set the destination of the segue (the settingsView) delegate to myself
			let settingsView = segue.destination as! SettingsViewController
			settingsView.delegate = self
		}
	}

	// MARK: - Settings Delegate Protocol Methods
	// When the user taps save, the delegate calls this method, sending back all of the data values from the settings panel
	func settingsViewController(viewController: SettingsViewController, gravitySetting: Float, bouncySetting: Float, boundingWallSetting: Bool, accelerometerSetting: Bool, activeBall: Int) {

		// Ceate a handle for the Standard User Defaults
		let userDefaults = UserDefaults.standard

//		let cgFloatGrav = gravitySetting * -40.0

		// Store values for the various settings in User Defaults
		userDefaults.setValue(gravitySetting, forKey:"gravityValue")
		userDefaults.setValue(bouncySetting, forKey:"bouncyness")
		userDefaults.setValue(boundingWallSetting, forKey:"boundingWallSetting")
		userDefaults.setValue(accelerometerSetting, forKey:"accelerometerSetting")
		userDefaults.setValue(activeBall, forKey:"activeBall")
		userDefaults.synchronize()

		// With the new physics now stored in NSUserDefaults, update the Physics for the scene
		scene.updateWorldPhysicsSettings()

		// Now dismiss the modal view controller
		self.dismiss(animated: true, completion: nil)
	}

	// If the user cancels the settings view, simply dismiss the modal view controller for settings
	func settingsViewController(viewController: SettingsViewController, cancelled: Bool) {
		self.dismiss(animated: true, completion: nil)
	}
}

