//
//  HamsLabelStyle.swift
//  HamsterUIKit
//
//  Created by Drake on 4/27/17.
//  Copyright © 2017 Howard Wang. All rights reserved.
//

import Foundation

///	label style(week, custom) for describing the value
public enum HamsLabelStyle {
	case week	//	default
	case custom([String])	//	can accept a set of descriptions

	static let weekLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

	func labels(length: Int) -> [String] {
		switch self {
		case .week:
			var ind: Int = Calendar(identifier: .gregorian).component(.weekday, from: Date()) - 1
			return configureLabels(array: HamsLabelStyle.weekLabels, length: length, start: &ind)
		case .custom(let arr):
			var ind = arr.count - 1
			return configureLabels(array: arr, length: length, start: &ind)
		}
	}

	fileprivate func configureLabels(array: [String], length: Int, start: inout Int) -> [String] {
		var labels = [String]()
		for _ in 0..<length {
			if start == -1 {
				start = array.count - 1
			}
			labels.insert(array[start], at: 0)
			start -= 1
		}
		return labels
	}
}
