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

