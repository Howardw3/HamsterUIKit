//
//  ChartsCore.swift
//  HamsterUIKit
//
//  Created by Howard on 2/13/17.
//  Copyright © 2017 Howard Wang. All rights reserved.
//

import Foundation
import UIKit

open class ChartsCore {
	fileprivate lazy var chartWidth:CGFloat = 300
	fileprivate lazy var chartHeight:CGFloat = 100
	fileprivate lazy var values: [CGFloat] = [0.0, 1.0]
	fileprivate var gapBetweenColumns:CGFloat = 20
	open var alignment: ChartAlignment = .justified
	open var horizonMargin:CGFloat = 0
	open var topBorder:CGFloat = 120
	open var bottomBorder:CGFloat = 10
	open var maxValue: CGFloat = 0
	open var columnWidth:CGFloat = 0
	
	
	open var height: CGFloat {
		return chartHeight - topBorder - bottomBorder
	}
	
	open var max: CGFloat {
		return getY(by: values.max()!)
	}
	
	open var min: CGFloat {
		return getY(by: values.min()!)
	}
	
	public init(with points: [CGFloat], frameSize:CGSize) {
		values = points
		chartWidth = frameSize.width
		chartHeight = frameSize.height
	}
	
	public init(with points: [CGFloat], frameSize:CGSize, offsets: ChartOffset) {
		values = points
		chartWidth = frameSize.width
		chartHeight = frameSize.height
		horizonMargin = offsets.horizon
		topBorder = offsets.top
		bottomBorder = offsets.bottom
		columnWidth = offsets.column
	}
	
	var contentWidth: CGFloat {
		return chartWidth - horizonMargin * 2
	}
	
	var unitWidth: CGFloat {
		return columnWidth + gapBetweenColumns
	}
	
	var contentMidWidth: CGFloat {
		return chartWidth / 2
	}
	
	open func getX(by column:Int) -> CGFloat {

		switch alignment {
		case .justified:
			let spacer = (chartWidth - horizonMargin * 2 - columnWidth * 2) /
				CGFloat((values.count - 1))
			var x:CGFloat = CGFloat(column) * spacer
			x += horizonMargin + columnWidth/2
			return x
		case .left:
			return horizonMargin + unitWidth * CGFloat(column)
		case .right:
			return contentWidth - unitWidth * CGFloat(values.count - column)
		case .center:
			let mid = CGFloat(values.count - 1) / 2.0
			let posDistance = round(mid - CGFloat(column))
			if CGFloat(column) < mid { // left side of mid point
				if values.count % 2 == 0 { //even
					return contentMidWidth - unitWidth * posDistance + gapBetweenColumns/2
				} else { // odd
					return contentMidWidth - unitWidth * posDistance - columnWidth/2
				}
			} else if CGFloat(column) > mid { // right side of mid point
				if values.count % 2 == 0 { //even
					return contentMidWidth + unitWidth * (-posDistance - 1) + gapBetweenColumns/2
				} else { // odd
					return contentMidWidth + unitWidth * -posDistance - columnWidth/2
				}
			} else { // at mid point, only happen when values.count is odd
				return contentMidWidth - columnWidth/2
			}
		}
	}
	
	/// gap between columns
	open var gapWidth: CGFloat {
		set {
			gapBetweenColumns = newValue
		} get {
			return gapBetweenColumns
		}
	}
	
	/// get y based on value
	open func getY(by value:CGFloat) -> CGFloat {
		var y:CGFloat = value / values.max()! * height
		if maxValue != 0.0 {
			if value > maxValue {
				y = height
			} else {
				y = value / maxValue * height
			}
		}
		return height + topBorder - y
	}
	
	/// get point by column
	open func getPoint(by column:Int) -> CGPoint {
		return CGPoint(x: getX(by: column),
		               y: getY(by: values[column]))
		
	}
	
}

public enum ChartAlignment {
	case left
	case right
	case center
	case justified
}
