//
//  HamsCurvePoint.swift
//  HamsterUIKit
//
//  Created by Howard on 4/19/17.
//  Copyright © 2017 Jiongzhi Wang. All rights reserved.
//

import Foundation
import UIKit

open class HamsCurveChartPoint {
	open var outerColor: UIColor
	open var innerColor: UIColor
	open var shadowColor: UIColor
	open var pointValue: CGFloat
	
	public init() {
		outerColor = UIColor.white
		innerColor = UIColor(red: 0.62, green: 0.73, blue: 0.91, alpha: 1.0)
		shadowColor = innerColor
		pointValue = 0
	}
}
