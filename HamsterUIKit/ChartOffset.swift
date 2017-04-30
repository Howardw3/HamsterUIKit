//
//  ChartOffset.swift
//  HamsterUIKit
//
//  Created by Howard on 4/23/17.
//  Copyright © 2017 Howard Wang. All rights reserved.
//

import Foundation

///	it will change the display of chart
public struct ChartOffset {
	let top: CGFloat
	let bottom: CGFloat
	let column: CGFloat
	let horizon: CGFloat
	public init(top: CGFloat, bottom: CGFloat, column: CGFloat, horizon: CGFloat){
		self.top = top
		self.bottom = bottom
		self.column = column
		self.horizon = horizon
	}
}
