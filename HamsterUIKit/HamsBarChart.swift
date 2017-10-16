//
//  GradientedBarChat.swift
//  Hamster
//
//  Created by Howard on 2/12/17.
//  Copyright © 2017 Howard Wang. All rights reserved.
//

import UIKit

///	the protocol represnts the data model object
public protocol HamsBarChartDataSource{
	///	implement this method to customize rectangular bars
	func barChart(_ barChart: HamsBarChart, barForChart indexPath: HamsIndexPath) -> HamsBarChartRect
	
	///	set number of charts
	func numberOfCharts(in barChart: HamsBarChart) -> Int
	
	/// set number of values in one chart
	func barChart(_ barChart: HamsBarChart, numberOfValuesInChart chart: Int) -> Int
}

/// this protocol represents the display and behaviour of the charts
@objc
public protocol HamsBarChartDelegate {
	///	should use this method to configue each chart
	@objc optional func barChart(_ barChart: HamsBarChart, configureForCharts chart: Int)
}

open class HamsBarChart: HamsChartBase {

	open weak var delegate: HamsBarChartDelegate?
	open var dataSource: HamsBarChartDataSource?

	open override var numberOfCharts: Int {
		return dataSource!.numberOfCharts(in: self)
	}
	
	open override func numberOfValues(in chart: Int) -> Int {
		guard let count = dataSource?.barChart(self, numberOfValuesInChart: chart) else { return 0 }
		return count
	}
	
	/// this will reload data and display
	open override func reloadData() {
		if dataSource != nil {
			self.configure()
			self.update()
			self.setNeedsDisplay()
		}
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	convenience init() {
		self.init(frame: CGRect.zero)
		setup()
	}
	
	override public init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	override func update() {
		delegate?.barChart!(self, configureForCharts: currentChart)
		super.update()

		if numberOfValues > 0 {
			for i in 0..<numberOfValues(in: currentChart) {
				let rect = dataSource?.barChart(self, barForChart: HamsIndexPath(column: i, view: currentChart))
				chartValues.append((rect?.value.sum)!)
			}
		} else { isDataEmpty = true }
		
		
	}
	
	override open func draw(_ rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()

		drawBackground(ctx: context!)
		drawBarchart(ctx: context!)
	}
	
	fileprivate func drawPlainBar(x: CGFloat, rect: HamsBarChartRect, height: CGFloat) {
		let path = UIBezierPath(roundedRect:CGRect(x: x,
		                                           y: base-height,
		                                           width: offsets.column,
		                                           height: height),
		                        byRoundingCorners:[.topRight, .topLeft],
		                        cornerRadii: CGSize(width: 5, height:  5))
		
		rect.color.colored().setFill()
		path.fill()
	}
	
	fileprivate func deawStackedBar(x: CGFloat, rect: HamsBarChartRect, height: CGFloat, vals: [CGFloat], scale: CGFloat) {
		var currSum:CGFloat = 0
		for i in (0..<vals.count).reversed() {
			
			if i < vals.count - 1 {
				let path = UIBezierPath(rect: CGRect(x: x, y:base-height+currSum, width:offsets.column, height:vals[i]*scale))
				currSum += vals[i]*scale
				rect.color.colored(rectIndex: i).setFill()
				path.fill()
			} else {
				let path = UIBezierPath(roundedRect:CGRect(x: x, y:base-height+currSum, width:offsets.column, height:vals[i]*scale),
				                        byRoundingCorners:[.topRight, .topLeft],
				                        cornerRadii: CGSize(width: 5, height:  5))
				currSum += vals[i]*scale
				rect.color.colored(rectIndex: i).setFill()
				path.fill()
			}
			
		}

	}
	
	fileprivate func drawGroupedBar(x: CGFloat, rect: HamsBarChartRect, height: CGFloat, vals: [CGFloat]) {
		let groupedBars = ChartsCore(with: vals, frameSize: CGSize(width: offsets.column, height: height))
		
		groupedBars.columnWidth = offsets.column / CGFloat(vals.count)
		groupedBars.topBorder = 0
		groupedBars.bottomBorder = 0
		groupedBars.alignment = .center
		groupedBars.gapWidth = 0
		
		var groupedscale:CGFloat = 1
		if let max = vals.max(), max > 0 {
			groupedscale = height / max
		}
		
		for j in 0..<vals.count {
			let groupedHeight = vals[j] * groupedscale
			let groupedPosX = groupedBars.getX(by: j)
			let path = UIBezierPath(rect: CGRect(x: groupedPosX + x, y:base-groupedHeight, width:groupedBars.columnWidth, height:groupedHeight))
			rect.color.colored(rectIndex: j).setFill()
			path.fill()
		}
	}
	
	fileprivate func drawBarchart(ctx: CGContext) {
		let bars = ChartsCore(with: chartValues, frameSize: frame.size, offsets: offsets)

		var scale:CGFloat = 1
		if let max = chartValues.max(), max > 0 {
			scale = (base - chartHeaderHeight) / max
		}

		for i in 0..<numberOfValues {
			let rect = (dataSource?.barChart(self, barForChart: HamsIndexPath(column: i, view: currentChart)))!
			let posX = bars.getX(by: i)
			let height = chartValues[i] * scale
			
			switch rect.value {
			case .plain( _):
				drawPlainBar(x: posX, rect: rect, height: height)

			case .stacked(let vals):
				deawStackedBar(x: posX, rect: rect, height: height, vals: vals, scale: scale)
			case .grouped(let vals):
				drawGroupedBar(x: posX, rect: rect, height: height, vals: vals)
				
			}

			drawLabels(column: i, posX: posX)
		}
		drawBaseline()
	}
	
	fileprivate func drawBaseline() {
		let path = UIBezierPath()
		
		path.move(to: CGPoint(x:offsets.horizon-5, y: base))
		path.addLine(to: CGPoint(x:frame.width - offsets.horizon + 5, y: base))
		UIColor.white.set()
		path.stroke()
	}
	
	
	fileprivate func drawLabels(column i:Int, posX: CGFloat) {
		let label = UILabel(frame: CGRect( x: posX-5, y: base+10, width: offsets.column + 10, height: 10))
		label.text = "\(labels[i])"
		label.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.regular)
		label.textColor = labelsColor
		label.adjustsFontSizeToFitWidth = true
		label.textAlignment = .center
		label.tag = i+2000
		
		self.addSubview(label)
	}
	
	fileprivate func drawBackground(ctx: CGContext) {
		let path = UIBezierPath(rect: bounds)

		switch filledStyle! {
		case .gradient(let top,let bottom):
			defaultColor = top
			ctx.saveGState()
			let colors = [top.cgColor, bottom.cgColor]
			let colorSpace = CGColorSpaceCreateDeviceRGB()
			let colorLocations:[CGFloat] = [0.0, 1.0]
			let gradient = CGGradient(colorsSpace: colorSpace,
			                          colors: colors as CFArray,
			                          locations: colorLocations)
			
			ctx.addPath(path.cgPath)
			ctx.clip()
			let endPoint = CGPoint(x:offsets.horizon, y: frame.height)
			let startPoint = CGPoint(x:offsets.horizon, y:0)
			
			ctx.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: .drawsBeforeStartLocation)
			ctx.restoreGState()
			
		case .plain(let color):
			defaultColor = color
			color.setFill()
			path.fill()
		}
	}
	
}

