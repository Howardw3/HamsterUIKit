//
//  HamsBarChartRect.swift
//  HamsterUIKit
//
//  Created by Howard on 4/25/17.
//  Copyright © 2017 Howard Wang. All rights reserved.
//

import Foundation
open class HamsBarChartRect {
	open var color: RectColorStyle
	open var value: RectValueStyle
	
	public init() {
		color = .plain(.white)
		value = .plain(0)
	}
}


public enum RectColorStyle {
	case plain(UIColor) 			///single color
	case arranged([UIColor])		///arrage color for grouped or stacked rect
	case randomed([UIColor])		///randomly pick color for all RectValueStyle
	
	static let defaultColor = UIColor(red: 0.69, green: 0.66, blue: 0.58, alpha: 1) // grey
	
	func colored(rectIndex index: Int = 0) -> UIColor {
		switch self {
		case .plain(let color):
			return color
		case .arranged(let colors):
			if index > colors.count - 1 {
				return colors.last ?? RectColorStyle.defaultColor
			}
			return colors[index]
		case .randomed(let colors):
			return colors[Int(arc4random_uniform(UInt32(colors.count)))]
		
		}
	}
}

public enum RectValueStyle {
	case plain(CGFloat)
	case grouped([CGFloat])
	case stacked([CGFloat])
	
	var sum:CGFloat {
		switch self {
		case .plain(let val):
			return val
		case .grouped(let vals):
			return vals.max() ?? 0
		case .stacked(let vals):
			return vals.reduce(0, +)
		}
	}
}
