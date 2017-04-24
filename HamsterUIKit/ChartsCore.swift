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
	
	open func getX(by column:Int) -> CGFloat {
		var x:CGFloat = CGFloat(column) * spacer
		x += horizonMargin + columnWidth/2
		return x
	}
	
	open var spacer: CGFloat {
		return (chartWidth - horizonMargin * 2 - columnWidth * 2) /
			CGFloat((values.count - 1))
	}
	
	open func getY(by graphPoint:CGFloat) -> CGFloat {
		var y:CGFloat = graphPoint / values.max()! * height
		if maxValue != 0.0 {
			if graphPoint > maxValue {
				y = height
			} else {
				y = graphPoint / maxValue * height
			}
		}
		return height + topBorder - y
	}
	
	open func getPoint(by column:Int) -> CGPoint {
		return CGPoint(x: getX(by: column),
		               y: getY(by: values[column]))
		
	}
	
}
