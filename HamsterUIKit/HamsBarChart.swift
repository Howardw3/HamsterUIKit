//
//  GradientedBarChat.swift
//  Hamster
//
//  Created by Drake on 2/12/17.
//  Copyright © 2017 Jiongzhi Wang. All rights reserved.
//

import UIKit

public protocol HamsBarChartDataSource{
	func barChart(_ barChart: HamsBarChart, barForChart indexPath: HamsIndexPath) -> HamsBarChartRect
	func numberOfViews(in barChart: HamsBarChart) -> Int
	func barChart(_ barChart: HamsBarChart, numberOfPointsInView view: Int) -> Int
}

public protocol HamsBarChartDelegate {
	func barChart(_ barChart: HamsBarChart, configureForViews view: Int)
}

open class HamsBarChart: UIView {

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
	fileprivate var base: CGFloat = 0

	open var delegate: HamsBarChartDelegate?
	open var dataSource: HamsBarChartDataSource?
	open var filledColor: HamsBackgoundStyle?
	open var labelsColor: UIColor!
	open var pointColor: UIColor!
	open var offsets = ChartOffset(top: 90, bottom: 40, column: 0, horizon: 0)
	open var pageIndicatorTintColor:UIColor?
	open var labelStyle: HamsLabelStyle!
	open var chartHeaderHeight: CGFloat = 0
	open var chartFooterHeight: CGFloat = 0 {
		didSet {
			base = frame.height - chartFooterHeight - 10
		}
	}

	
	fileprivate func initialize() {
		removeLabel()
		setTitle()
		labelsColor = UIColor(red: 0.53, green: 0.55, blue: 0.56, alpha: 1.0)
		pointColor = UIColor(red: 0.53, green: 0.55, blue: 0.56, alpha: 1.0)
		offsets = ChartOffset(top: 90, bottom: 40, column: 0, horizon: 0)
		labelStyle = .week
		filledColor = .plain(defaultColor)
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
		guard let count = dataSource?.barChart(self, numberOfPointsInView: view) else { return 0 }
		return count
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
	
	fileprivate func setup() {
		
		chartHeaderHeight = frame.height/5 + 20
		chartFooterHeight = frame.height/5
		
		
		
		self.backgroundColor = .clear
		defaultColor = UIColor(red: 0.99, green: 0.30, blue: 0.03, alpha: 1.0)
		
		pageControl.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(pageControl)
		pageControl.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		pageControl.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		pageControl.widthAnchor.constraint(equalToConstant: chartFooterHeight+5).isActive = true
		
		self.swipeGestureLeft.direction = .left
		self.swipeGestureRight.direction = .right
		
		// add gesture target
		self.swipeGestureLeft.addTarget(self, action: #selector(handleSwipeLeft(_:)))
		self.swipeGestureRight.addTarget(self, action: #selector(handleSwipeRight(_:)))
		
		// add gesture into view
		self.addGestureRecognizer(self.swipeGestureLeft)
		self.addGestureRecognizer(self.swipeGestureRight)
		
		
		initialize()
	}
	
	fileprivate func update() {
		
		pageControl.numberOfPages = numberOfViews
		graphPoints = []
		numberOfPoints = numberOfPoints(in: currentView)
		
		delegate?.barChart(self, configureForViews: currentView)
		labels = labelStyle.labels(length: numberOfPoints)
		if numberOfPoints > 0 {
			for i in 0..<numberOfPoints(in: currentView) {
				let rect = dataSource?.barChart(self, barForChart: HamsIndexPath(column: i, view: currentView))
				graphPoints.append((rect?.value.sum)!)
			}
		} else {
			isDataEmpty = true
		}
		if numberOfViews > 1 {
			pageControl.isHidden = false
			pageControl.isEnabled = false
		} else {
			pageControl.isHidden = true
			pageControl.isEnabled = true
		}
	}
	
	override open func draw(_ rect: CGRect) {
		
		
		let context = UIGraphicsGetCurrentContext()

		drawBackground(ctx: context!)
		drawBarchart(ctx: context!)
	}
	
	fileprivate func setTitle() {
		let title = UILabel(frame: CGRect( x: 0, y: chartHeaderHeight-39, width: frame.width, height: 29))
		title.text = "Title"
		title.font = UIFont.systemFont(ofSize: 24, weight: UIFontWeightSemibold)
		title.adjustsFontSizeToFitWidth = true
		title.textColor = UIColor.white
		title.textAlignment = .center
		
		self.addSubview(title)
	}
	
	fileprivate func drawBarchart(ctx: CGContext) {
		let bars = ChartsCore(with: graphPoints, frameSize: frame.size, offsets: offsets)

		
		var scale:CGFloat = 1
		if let max = graphPoints.max(), max > 0 {
			scale = (base - chartHeaderHeight) / max
		}

		for i in 0..<numberOfPoints {
			let rect = (dataSource?.barChart(self, barForChart: HamsIndexPath(column: i, view: currentView)))!
			let posX = bars.getX(by: i)
			
			let height = graphPoints[i] * scale
			switch rect.value {
			case .plain( _):
				
				let path = UIBezierPath(roundedRect:CGRect(x: posX, y:base-height, width:offsets.column, height:height),
				                        byRoundingCorners:[.topRight, .topLeft],
				                        cornerRadii: CGSize(width: 5, height:  5))
				rect.color.colored().setFill()
				path.fill()
			case .stacked(let vals):
				var currSum:CGFloat = 0
				for i in (0..<vals.count).reversed() {
					
					if i < vals.count - 1 {
						let path = UIBezierPath(rect: CGRect(x: posX, y:base-height+currSum, width:offsets.column, height:vals[i]*scale))
						currSum += vals[i]*scale
						rect.color.colored(rectIndex: i).setFill()
						path.fill()
					} else {
						let path = UIBezierPath(roundedRect:CGRect(x: posX, y:base-height+currSum, width:offsets.column, height:vals[i]*scale),
						                        byRoundingCorners:[.topRight, .topLeft],
						                        cornerRadii: CGSize(width: 5, height:  5))
						currSum += vals[i]*scale
						rect.color.colored(rectIndex: i).setFill()
						path.fill()
					}
					
				}
			case .grouped(let vals):
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
					let path = UIBezierPath(rect: CGRect(x: groupedPosX + posX, y:base-groupedHeight, width:groupedBars.columnWidth, height:groupedHeight))
					rect.color.colored(rectIndex: j).setFill()
					path.fill()
				}
			}

			drawLabels(column: i, posX: posX)
		}

		let path = UIBezierPath()

		path.move(to: CGPoint(x:bars.horizonMargin-5, y: base))
		path.addLine(to: CGPoint(x:frame.width - bars.horizonMargin + 5, y: base))
		UIColor.white.set()
		path.stroke()

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

	fileprivate func drawLabels(column i:Int, posX: CGFloat) {
		let label = UILabel(frame: CGRect( x: posX-5, y: base+10, width: offsets.column + 10, height: 10))
		label.text = "\(labels[i])"
		label.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightRegular)
		label.textColor = UIColor.white
		label.adjustsFontSizeToFitWidth = true
		label.textAlignment = .center
		label.tag = i+2000
		
		self.addSubview(label)
	}
	
	fileprivate func drawBackground(ctx: CGContext) {
		let path = UIBezierPath(rect: bounds)

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
}

