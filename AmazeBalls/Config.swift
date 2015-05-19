//
//  Config.swift
//  Amazeballs
//
//  Created by Daniel Flax on 5/18/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

import Foundation
import UIKit

//UI Constants
let ScreenWidth  = UIScreen.mainScreen().bounds.size.width
let ScreenHeight = UIScreen.mainScreen().bounds.size.height
let ScreenCenter = CGPoint(x: ScreenWidth / 2.0, y: ScreenHeight / 2.0)
let ScreenSize   = CGSize(width: ScreenWidth, height: ScreenHeight)
let ScreenRect   = CGRect(x: 0.0, y: 0.0, width: ScreenWidth, height: ScreenHeight)

// Device type - true if iPad or iPad Simulator
let isPad: Bool = {
	if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
		return true
	} else {
		return false
	}
	}()

//Random Integer generator
func randomNumber(#minX:UInt32, #maxX:UInt32) -> Int {
	let result = (arc4random() % (maxX - minX + 1)) + minX
	return Int(result)
}

// Collision categories
struct CollisionCategories{
	static let Ball    : UInt32 = 0x1 << 0
	static let Floor   : UInt32 = 0x1 << 1
	static let EdgeBody: UInt32 = 0x1 << 2
}

// Extensions to enable CGFloat casting
extension Int {
	var cf: CGFloat { return CGFloat(self) }
	var f:  Float   { return Float(self) }
}
extension Float {
	var cf: CGFloat { return CGFloat(self) }
	var f:  Float   { return self }
}
extension Double {
	var cf: CGFloat { return CGFloat(self) }
	var f:  Float   { return Float(self) }
}

