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
	func numberOfViews(in curveChart: HamsCurveChart) -> Int
	
	func curveChart(_ curveChart: HamsCurveChart, numberOfPointsInView view: Int) -> Int
}

public protocol HamsCurveChartDelegate {
	func curveChart(_ curveChart: HamsCurveChart, configureForViews view: Int)
}

public enum EndpointType {
	case none
	case zero
	case max
	case auto
	case value(CGFloat)
	case average(CGFloat, CGFloat)
}

open class HamsCurveChart: UIControl {
	
	fileprivate var maximum:CGFloat = 0
	fileprivate var labelWidth:CGFloat = 0
	fileprivate var pageControl = UIPageControl()
	fileprivate var touchedPoint:CGPoint = CGPoint.zero
	fileprivate var numberOfPoints = 0
	fileprivate var isDataEmpty = false
	fileprivate var labels = [String]()
	fileprivate var currentView: Int = 0
	fileprivate let swipeGestureLeft = UISwipeGestureRecognizer()
	fileprivate let swipeGestureRight = UISwipeGestureRecognizer()
	fileprivate var graphPoints = [CGFloat]()
	fileprivate var defaultColor: UIColor!
	
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
	
	open var filledColor: HamsBackgoundStyle?
	open var labelsColor: UIColor!
	open var pointColor: UIColor!
	open var offsets: ChartOffset!
	open var pageIndicatorTintColor:UIColor?
	open var labelStyle: HamsLabelStyle!
	open var suggestValue: Int = 0 {
		didSet{
			if suggestValue > 0 {
				maximum = CGFloat(suggestValue) * 4.0 / 3.0
			}
		}
	}
	
	fileprivate func initialize() {
		startPoint = .auto
		endPoint = .auto
		labelsColor = UIColor(red: 0.53, green: 0.55, blue: 0.56, alpha: 1.0)
		pointColor = UIColor(red: 0.53, green: 0.55, blue: 0.56, alpha: 1.0)
		offsets = ChartOffset(top: 90, bottom: 40, column: 0, horizon: 0)
		labelStyle = .week
		suggestValue = 0
		filledColor = .plain(defaultColor)
	}
	
	open var maxValue:CGFloat {
		set{
			if suggestValue == 0 {
				maximum = newValue
			}
		} get { return maximum }
	}
	
	open var numberOfViews: Int { return dataSource!.numberOfViews(in: self)}
	
	open func reloadData() {
		if dataSource != nil {
			self.initialize()
			self.update()
			self.setNeedsDisplay()
		}
	}
	
	open func numberOfPoints(in view: Int) -> Int {
		guard let count = dataSource?.curveChart(self, numberOfPointsInView: view) else { return 0 }
		return count
	}
	
	
	fileprivate func setup() {
		
		self.backgroundColor = .clear
		defaultColor = UIColor(red: 0.99, green: 0.30, blue: 0.03, alpha: 1.0)
		
		pageControl.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(pageControl)
		pageControl.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		pageControl.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		pageControl.widthAnchor.constraint(equalToConstant: 50).isActive = true
		
		self.swipeGestureLeft.direction = .left
		self.swipeGestureRight.direction = .right
		
		// add gesture target
		self.swipeGestureLeft.addTarget(self, action: #selector(handleSwipeLeft(_:)))
		self.swipeGestureRight.addTarget(self, action: #selector(handleSwipeRight(_:)))
		
		// add gesture into view
		self.addGestureRecognizer(self.swipeGestureLeft)
		self.addGestureRecognizer(self.swipeGestureRight)
		
	}
	
	fileprivate func update() {
		
		pageControl.numberOfPages = numberOfViews
		graphPoints = []
		numberOfPoints = numberOfPoints(in: currentView)

		labels = labelStyle.labels(length: numberOfPoints)
		if numberOfPoints > 0 {
			for i in 0..<numberOfPoints(in: currentView) {
				let curveChartPoint = dataSource?.curveChart(self, pointForChart: HamsIndexPath(column: i, view: currentView))
				graphPoints.append((curveChartPoint?.pointValue)!)
			}
			if graphPoints.max() == 0 {
				isDataEmpty = true
			} else {
				isDataEmpty = false
			}
		} else {
			graphPoints = [0, 0]
			isDataEmpty = true
		}
		
		delegate?.curveChart(self, configureForViews: currentView)
		
		if let val = value(type: startPoint, left: true) {
			graphPoints = [val] + graphPoints
		}
		
		if let val = value(type: endPoint, left: false) {
			graphPoints = graphPoints + [val]
		}
		numberOfPoints = graphPoints.count
	}
	
	override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		super.beginTracking(touch, with: event)
		touchedPoint = touch.location(in: self)
		setNeedsDisplay()
		return true
	}
	
	override open func draw(_ rect: CGRect) {
		
		removeLabel()
		let context = UIGraphicsGetCurrentContext()
		pageControl.pageIndicatorTintColor = pageIndicatorTintColor
		
		let quadCurve = QuadCurveAlgorithm(with: graphPoints, frameSize: frame.size, offsets: offsets)
		
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
			x: quadCurve.getX(by: graphPoints.count - 1),
			y:height))
		graphPath.addLine(to: CGPoint(
			x:quadCurve.getX(by: 0),
			y:height))
		graphPath.close()
		
		
		switch filledColor! {
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
	
	fileprivate func removeLabel(tag: Int) {
		for sub in self.subviews {
			if sub.tag == tag {
				sub.removeFromSuperview()
			}
		}
	}
	
	fileprivate func removeLabel() {
		for subview in self.subviews {
			if subview is UILabel {
				subview.removeFromSuperview()
			}
		}
	}
	
	fileprivate func drawPoint(ctx: CGContext, quadCurve: QuadCurveAlgorithm) {
		var start = 0, end = numberOfPoints
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
				let curveChartPoint = dataSource?.curveChart(self, pointForChart: HamsIndexPath(column: ind, view: currentView))
				
				let outerCircle = drawOuterCircle(ctx: ctx, point: point, curveChartPoint: curveChartPoint!)
				
				let innerCircle = drawInnerCircle(point: point, curveChartPoint: curveChartPoint!)
				outerCircle.append(innerCircle)
				

				let touchArea = UIBezierPath(arcCenter: point, radius: 30, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
				touchArea.append(outerCircle)
				if touchArea.contains(touchedPoint) {
					
					removeLabel(tag: 12138)
					// add touched label
					let pointValueLabel = UILabel(frame: CGRect(x: point.x - labelWidth / 2, y: point.y-8-7-10, width: labelWidth, height: 14))
					pointValueLabel.text = "\(Int(graphPoints[i]))"
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
		let label = UILabel(frame: CGRect( x: point.x - labelWidth / 2, y: 0, width: labelWidth, height: 24))
		label.text = "\(labels[i-1])"
		label.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
		label.tag = i+2000
		label.textColor = labelsColor
		label.textAlignment = .center
		self.addSubview(label)
	}
	
	fileprivate func capture() -> UIImageView {
		let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
		let image = renderer.image { ctx in
			self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
		}
		
		return UIImageView(image: image)
	}
	
	// increase page number
	@objc fileprivate func handleSwipeLeft(_ gesture: UISwipeGestureRecognizer) {
		if self.pageControl.currentPage < numberOfViews - 1 {
			self.pageControl.currentPage += 1
			currentView = pageControl.currentPage
			
			let imageView = self.capture()
			imageView.frame = self.frame
			superview?.addSubview(imageView)
			self.center.x += self.frame.width
			
			reloadData()
			UIView.animate(withDuration: 0.5, animations: {
				imageView.center.x -= self.frame.width
				self.center.x -= self.frame.width
			})
		} else {
			UIView.animate(withDuration: 0.5, animations: {
				self.center.x -= 50
			}, completion: {(f) in
				self.center.x += 50
			})
		}
	}
	
	// reduce page number
	@objc fileprivate func handleSwipeRight(_ gesture: UISwipeGestureRecognizer) {
		
		
		if self.pageControl.currentPage != 0 {
			self.pageControl.currentPage -= 1
			currentView = pageControl.currentPage
			
			let imageView = self.capture()
			imageView.frame = self.frame
			superview?.addSubview(imageView)
			self.center.x -= self.frame.width
			
			reloadData()
			UIView.animate(withDuration: 0.5, animations: {
				imageView.center.x += self.frame.width
				self.center.x += self.frame.width
			})
		} else {
			UIView.animate(withDuration: 0.5, animations: {
				self.center.x += 50
			}, completion: {(f) in
				self.center.x -= 50
			})
		}
		
		
	}
	
	fileprivate func value(type: EndpointType, left: Bool = true) -> CGFloat? {
		switch type {
		case .auto:
			if left {
				return (graphPoints[0] + graphPoints[1]) / 2
			} else {
				return (graphPoints[back: 1] + graphPoints[back: 2]) / 2
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





