//
//  HamsCurvePoint.swift
//  HamsterUIKit
//
//  Created by Howard on 4/19/17.
//  Copyright © 2017 Jiongzhi Wang. All rights reserved.
//

import Foundation
import UIKit

///	changes the display of points in curve chart
open class HamsCurveChartPoint {
	///	outer ring color, default is white
	open var outerColor: UIColor
	
	/// inner circle color, default is blue
	open var innerColor: UIColor
	
	/// shadow color around point, default is inner color
	open var shadowColor: UIColor
	
	/// set value for representing in graph
	open var pointValue: CGFloat
	
	///	inner radius for inner circle
	open var innerRadius: CGFloat
	
	/// outer radius for outer circle
	open var outerRadius: CGFloat
	
	public init() {
		outerColor = UIColor.white
		innerColor = UIColor(red: 0.62, green: 0.73, blue: 0.91, alpha: 1.0)
		shadowColor = innerColor
		pointValue = 0
		outerRadius = 4
		innerRadius = 7.5
	}
}
