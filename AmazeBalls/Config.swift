//
//  Config.swift
//  Amazeballs
//
//  Created by Daniel Flax on 5/18/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
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

// Calculate the right size for the settingsViewController ball images
var settingsBallSize: CGFloat {
	return ((ScreenWidth - 50) / 8)
}

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

// Determine the device type
private let DeviceList = [
	/* iPod 5 */          "iPod5,1": "iPod Touch 5",
	/* iPhone 4 */        "iPhone3,1":  "iPhone 4", "iPhone3,2": "iPhone 4", "iPhone3,3": "iPhone 4",
	/* iPhone 4S */       "iPhone4,1": "iPhone 4S",
	/* iPhone 5 */        "iPhone5,1": "iPhone 5", "iPhone5,2": "iPhone 5",
	/* iPhone 5C */       "iPhone5,3": "iPhone 5C", "iPhone5,4": "iPhone 5C",
	/* iPhone 5S */       "iPhone6,1": "iPhone 5S", "iPhone6,2": "iPhone 5S",
	/* iPhone 6 */        "iPhone7,2": "iPhone 6",
	/* iPhone 6 Plus */   "iPhone7,1": "iPhone 6 Plus",
	/* iPad 2 */          "iPad2,1": "iPad 2", "iPad2,2": "iPad 2", "iPad2,3": "iPad 2", "iPad2,4": "iPad 2",
	/* iPad 3 */          "iPad3,1": "iPad 3", "iPad3,2": "iPad 3", "iPad3,3": "iPad 3",
	/* iPad 4 */          "iPad3,4": "iPad 4", "iPad3,5": "iPad 4", "iPad3,6": "iPad 4",
	/* iPad Air */        "iPad4,1": "iPad Air", "iPad4,2": "iPad Air", "iPad4,3": "iPad Air",
	/* iPad Air 2 */      "iPad5,1": "iPad Air 2", "iPad5,3": "iPad Air 2", "iPad5,4": "iPad Air 2",
	/* iPad Mini */       "iPad2,5": "iPad Mini", "iPad2,6": "iPad Mini", "iPad2,7": "iPad Mini",
	/* iPad Mini 2 */     "iPad4,4": "iPad Mini", "iPad4,5": "iPad Mini", "iPad4,6": "iPad Mini",
	/* iPad Mini 3 */     "iPad4,7": "iPad Mini", "iPad4,8": "iPad Mini", "iPad4,9": "iPad Mini",
	/* Simulator */       "x86_64": "Simulator", "i386": "Simulator"
]

// Extension to UIDevice. Usage: let modelName = UIDevice.currentDevice().modelName
public extension UIDevice {
	var modelName: String {
		var systemInfo = utsname()
		uname(&systemInfo)

		let machine = systemInfo.machine
		let mirror = reflect(machine)
		var identifier = ""

		for i in 0..<mirror.count {
			if let value = mirror[i].1.value as? Int8 where value != 0 {
				identifier.append(UnicodeScalar(UInt8(value)))
			}
		}
		return DeviceList[identifier] ?? identifier
	}
}

