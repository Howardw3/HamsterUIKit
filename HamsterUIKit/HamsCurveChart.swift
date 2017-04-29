//
//  HamsCurveChart.swift
//  HamsterUIKit
//
//  Created by Howard on 2/10/17.
//  Copyright © 2017 Jiongzhi Wang. All rights reserved.
//

import UIKit

public protocol HamsCurveChartDataSource{
	func curveChart(_ curveChart: HamsCurveChart, pointForChart indexPath: HamsIndexPath) -> HamsCurveChartPoint
	func numberOfCharts(in curveChart: HamsCurveChart) -> Int
	
	func curveChart(_ curveChart: HamsCurveChart, numberOfValuesInChart chart: Int) -> Int
}

public protocol HamsCurveChartDelegate {
	func curveChart(_ curveChart: HamsCurveChart, configureForCharts chart: Int)
}

public enum EndpointType {
	case none
	case zero
	case max
	case auto
	case value(CGFloat)
	case average(CGFloat, CGFloat)
}

open class HamsCurveChart: HamsChartBase {
	
	fileprivate var maximum:CGFloat = 0
	fileprivate var labelWidth:CGFloat = 0
	fileprivate var quadCurve: QuadCurveAlgorithm!
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
	
	open var delegate: HamsCurveChartDelegate?
	open var dataSource: HamsCurveChartDataSource?
	
	open var startPoint:EndpointType!
	open var endPoint:EndpointType!
	
	open var suggestValue: Int = 0 {
		didSet{
			if suggestValue > 0 {
				maximum = CGFloat(suggestValue) * 4.0 / 3.0
			}
		}
	}
	
	override func configure() {
		super.configure()
		startPoint = .auto
		endPoint = .auto
		suggestValue = 0
		titleColor = .black
//		offsets = ChartOffset(top: 0, bottom: 0, column: 30, horizon: 50)
		labelsColor = .black
	}
	
	open var maxValue:CGFloat {
		set{
			if suggestValue == 0 {
				maximum = newValue
			}
		} get { return maximum }
	}
	
	open override var numberOfCharts: Int {
		return dataSource!.numberOfCharts(in: self)
	}
	
	open override func reloadData() {
		if dataSource != nil {
			self.configure()
			self.update()
			self.setNeedsDisplay()
		}
	}
	
	open override func numberOfValues(in chart: Int) -> Int {
		guard let count = dataSource?.curveChart(self, numberOfValuesInChart: chart) else { return 0 }
		return count
	}
	
	override func update() {
		delegate?.curveChart(self, configureForCharts: currentChart)
		super.update()
		
		if numberOfValues > 0 {
			for i in 0..<numberOfValues(in: currentChart) {
				let curveChartPoint = dataSource?.curveChart(self, pointForChart: HamsIndexPath(column: i, view: currentChart))
				chartValues.append((curveChartPoint?.pointValue)!)
			}
			if chartValues.max() == 0 {
				isDataEmpty = true
			} else {
				isDataEmpty = false
			}
		} else {
			chartValues = [0, 0]
			isDataEmpty = true
		}
		
		if let val = value(type: startPoint, left: true) {
			chartValues = [val] + chartValues
		}
		
		if let val = value(type: endPoint, left: false) {
			chartValues = chartValues + [val]
		}
		numberOfValues = chartValues.count
	}
	
	override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		super.beginTracking(touch, with: event)
		touchedPoint = touch.location(in: self)
		setNeedsDisplay()
		return true
	}
	
	override open func draw(_ rect: CGRect) {
		
		let context = UIGraphicsGetCurrentContext()
		pageControl.pageIndicatorTintColor = pageIndicatorTintColor

		let contentOffsets = ChartOffset(top: offsets.top + chartHeaderHeight,
		                                 bottom: offsets.bottom + chartFooterHeight,
		                                 column: offsets.column,
		                                 horizon: offsets.horizon)
		let quadCurve = QuadCurveAlgorithm(with: chartValues, frameSize: frame.size, offsets: contentOffsets)
		
		quadCurve.maxValue = maximum
		
		drawGraph(ctx: context!, quadCurve: quadCurve)
		
		if suggestValue > 0 && !isDataEmpty{
			drawSuggestion(quadCurve: quadCurve)
		}
		labelWidth = quadCurve.unitWidth
		
		drawPoint(ctx: context!, quadCurve: quadCurve)
	}
	
	fileprivate func drawSuggestion(quadCurve: QuadCurveAlgorithm) {
		let pos:CGFloat = quadCurve.getY(by: CGFloat(suggestValue)) - 10
		
		drawSuggShape(pos: pos)
		drawDash(pos: pos)
		drawSuggLabel(pos: pos)
	}
	
	fileprivate func drawSuggShape(pos: CGFloat) {
		let path = UIBezierPath()
		path.move(to: CGPoint(x: 0, y: pos))
		path.addLine(to: CGPoint(x: 25, y: pos))
		path.addQuadCurve(to: CGPoint(x: 33, y: pos + 2), controlPoint: CGPoint(x: 33, y: pos))
		path.addLine(to: CGPoint(x: 40, y: pos+10))
		path.addQuadCurve(to: CGPoint(x: 30, y: pos + 20), controlPoint: CGPoint(x: 34, y: pos + 20))
		path.addLine(to: CGPoint(x: 30, y: pos+20))
		path.addLine(to: CGPoint(x: 0, y: pos+20))
		
		path.lineCapStyle = .round
		path.lineJoinStyle = .round
		defaultColor.set()
		path.fill()
	}
	
	fileprivate func drawDash(pos: CGFloat) {
		let dash = UIBezierPath()
		dash.move(to: CGPoint(x: 46, y: pos+10))
		dash.addLine(to: CGPoint(x: frame.width, y: pos+10))
		dash.lineWidth = 4
		let dashes = [dash.lineWidth * 0,dash.lineWidth * 4.1]
		dash.setLineDash(dashes, count: dashes.count, phase: 0.0)
		
		dash.lineCapStyle = .round
		defaultColor.set()
		dash.stroke()
	}
	
	fileprivate func drawSuggLabel(pos: CGFloat) {
		removeLabel(tag: 12306)
		let suggLabel = UILabel()
		suggLabel.frame = CGRect(x: 4, y: pos + 3.25, width: 30, height: 14)
		
		suggLabel.text = "\(suggestValue)"
		suggLabel.textAlignment = .center
		suggLabel.textColor = UIColor.white
		suggLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
		suggLabel.tag = 12306
		suggLabel.adjustsFontSizeToFitWidth = true
		self.addSubview(suggLabel)
	}
	
	fileprivate func drawGraph(ctx: CGContext, quadCurve: QuadCurveAlgorithm) {
		let height = frame.height
		
		let graphPath = quadCurve.quadCurvePath
		graphPath.addLine(to: CGPoint(
			x: quadCurve.getX(by: chartValues.count - 1),
			y:height))
		graphPath.addLine(to: CGPoint(
			x:quadCurve.getX(by: 0),
			y:height))
		graphPath.close()
		
		
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
			
			ctx.addPath(graphPath.cgPath)
			ctx.clip()
			var startPoint = CGPoint.zero
			if quadCurve.maxValue == 0{
				startPoint = CGPoint(x:offsets.horizon, y: quadCurve.max)
			} else {
				startPoint = CGPoint(x:offsets.horizon, y: quadCurve.getY(by: quadCurve.maxValue))
			}
			let endPoint = CGPoint(x:offsets.horizon, y:height)
			
			ctx.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
			ctx.restoreGState()
			
		case .plain(let color):
			defaultColor = color
			color.setFill()
			graphPath.fill()
		}
		
	}
	

	
	fileprivate func drawPoint(ctx: CGContext, quadCurve: QuadCurveAlgorithm) {
		var start = 0, end = numberOfValues
		if (value(type: startPoint) != nil){
			start = 1
		}
		if (value(type: endPoint) != nil){
			end -= 1
		}
		for i in start..<end {
			let point = quadCurve.getPoint(by: i)

			if !isDataEmpty {
				let ind = i - start
				let curveChartPoint = dataSource?.curveChart(self, pointForChart: HamsIndexPath(column: ind, view: currentChart))
				
				let outerCircle = drawOuterCircle(ctx: ctx, point: point, curveChartPoint: curveChartPoint!)
				
				let innerCircle = drawInnerCircle(point: point, curveChartPoint: curveChartPoint!)
				outerCircle.append(innerCircle)
				

				let touchArea = UIBezierPath(arcCenter: point, radius: 30, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
				touchArea.append(outerCircle)
				if touchArea.contains(touchedPoint) {
					
					removeLabel(tag: 12138)
					// add touched label
					let pointValueLabel = UILabel(frame: CGRect(x: point.x - labelWidth / 2, y: point.y-8-7-10, width: labelWidth, height: 14))
					pointValueLabel.text = "\(Int(chartValues[i]))"
					pointValueLabel.font = UIFont.systemFont(ofSize: 12)
					pointValueLabel.textAlignment = .center
					pointValueLabel.tag = 12138
					self.addSubview(pointValueLabel)
					
					
				}
			}
			drawLabels(column: i, point: point)
			
		}
	}
	
	fileprivate func drawOuterCircle(ctx: CGContext, point: CGPoint, curveChartPoint: HamsCurveChartPoint) -> UIBezierPath {
		ctx.saveGState()
		let path = UIBezierPath(arcCenter: point,
		                          radius: 7.5,
		                          startAngle: 0,
		                          endAngle: 2 * .pi,
		                          clockwise: true)
		ctx.setShadow(offset: CGSize(width: 1.0, height: 3.0),
		              blur: 6,
		              color: curveChartPoint.innerColor.cgColor)
		curveChartPoint.outerColor.setFill()
		path.fill()
		
		ctx.restoreGState()
		return path
	}
	
	fileprivate func drawInnerCircle(point: CGPoint, curveChartPoint: HamsCurveChartPoint) -> UIBezierPath {
		let path = UIBezierPath(arcCenter: point,
		                          radius: 4,
		                          startAngle: 0,
		                          endAngle: 2 * .pi,
		                          clockwise: true)
		
		curveChartPoint.innerColor.setFill()
		path.fill()
		return path
	}
	
	fileprivate func drawLabels(column i:Int, point: CGPoint) {
		let label = UILabel(frame: CGRect( x: point.x - labelWidth / 2, y: chartHeaderHeight - 10, width: labelWidth, height: 10))
		label.text = "\(labels[i-1])"
		label.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
		label.textColor = labelsColor
		label.textAlignment = .center
		label.tag = i+2000
		self.addSubview(label)
	}
	
	fileprivate func value(type: EndpointType, left: Bool = true) -> CGFloat? {
		switch type {
		case .auto:
			if left {
				return (chartValues[0] + chartValues[1]) / 2
			} else {
				return (chartValues[back: 1] + chartValues[back: 2]) / 2
			}
		case .zero:
			return 0
		case .average(let a, let b):
			return (a + b) / 2
		case .value(let a):
			return a
		case .max:
			return maxValue
		case .none:
			return nil
		}
	}
}





