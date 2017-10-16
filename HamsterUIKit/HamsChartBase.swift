//
//  HamsChartBase.swift
//  HamsterUIKit
//
//  Created by Howard on 4/28/17.
//  Copyright © 2017 Howard Wang. All rights reserved.
//

import Foundation

open class HamsChartBase:UIControl {
	
	/// page control in footer
	var pageControl = UIPageControl()
	
	/// touched point record for showing label or view
	var touchedPoint:CGPoint = CGPoint.zero
	
	/// total of values
	var numberOfValues = 0
	
	/// default is false
	var isDataEmpty = false
	
	/// current number of chart
	var currentChart: Int = 0
	
	/// from right to left
	let swipeGestureLeft = UISwipeGestureRecognizer()
	
	/// from left to right
	let swipeGestureRight = UISwipeGestureRecognizer()
	
	/// chart data, only support positive value right now
	var chartValues = [CGFloat]()
	
	/// default color for backgroud and some conponents
	///
	var defaultColor: UIColor!
	
	/// position when value = 0. 
	/// default is frame.height - chartFooterHeight - 10
	var base: CGFloat = 0
	
	/// description for each column
	var labels = [String]()
	
	/// label (week, costom label) height
	var labelHeight: CGFloat = 10
	
	/// padding between chartHeaderHeight and content
	var paddingHeight: CGFloat = 20
	
	/// in curve chart fill graph
	///	in barchart fill background
	open var filledStyle: HamsBackgoundStyle?
	
	open var offsets: ChartOffset!
	
	open var pageIndicatorTintColor:UIColor?
	
	open var labelStyle: HamsLabelStyle!
	
	open var labelsColor: UIColor = .white
	
	open var chartHeaderHeight: CGFloat!
	
	open var chartFooterHeight: CGFloat! {
		didSet {
			base = frame.height - chartFooterHeight - 10
		}
	}
	
	///	change title label in header
	open var title:String = "Title"
	
	/// change title color
	open var titleColor:UIColor = .white
	
	///	variables can be changed in configureForChart
	func configure(){
		removeLabel()
		if frame.height/5 > 40.0 {
			chartFooterHeight = 60
			chartHeaderHeight = 60
		} else {
			chartHeaderHeight = frame.height/5 + 30
			chartFooterHeight = frame.height/5
		}
		
		title = "Title"
		titleColor = .white
		offsets = ChartOffset(top: 0, bottom: 0, column: 30, horizon: 50)
		labelStyle = .week
		labelsColor = .white
		filledStyle = .plain(defaultColor)
		
		pageControl.widthAnchor.constraint(equalToConstant: chartFooterHeight+5).isActive = true
	}
	
	///	set title in header
	func setTitle() {
		let titleLabel = UILabel(frame: CGRect( x: 0, y: chartHeaderHeight-49, width: frame.width, height: 29))
		titleLabel.text = title
		titleLabel.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.semibold)
		titleLabel.adjustsFontSizeToFitWidth = true
		titleLabel.textColor = titleColor
		titleLabel.textAlignment = .center
		
		self.addSubview(titleLabel)
	}
	
	///	the subclass must override this variable, default is 0
	open var numberOfCharts: Int { return 0 }
	
	/// the subclass must override this function, default return 0
	open func numberOfValues(in chart: Int) -> Int { return 0 }
	
	///	reload function for redraw chart and reload data
	open func reloadData() { }
	
	///	get number of charts and values from controller
	///	reload data
	func update() {
		pageControl.numberOfPages = numberOfCharts
		chartValues = []
		numberOfValues = numberOfValues(in: currentChart)
		setTitle()
		labels = labelStyle.labels(length: numberOfValues)
		
		if numberOfCharts > 1 {
			pageControl.isHidden = false
			pageControl.isEnabled = false
		} else {
			pageControl.isHidden = true
			pageControl.isEnabled = true
		}
	}
	
	///	setup conponent when chart is created
	func setup() {
		
		self.backgroundColor = .clear
		defaultColor = UIColor(red: 0.99, green: 0.30, blue: 0.03, alpha: 1.0)
		
		pageControl.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(pageControl)
		pageControl.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		pageControl.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		
		self.swipeGestureLeft.direction = .left
		self.swipeGestureRight.direction = .right
		
		// add gesture target
		self.swipeGestureLeft.addTarget(self, action: #selector(handleSwipeLeft(_:)))
		self.swipeGestureRight.addTarget(self, action: #selector(handleSwipeRight(_:)))
		
		// add gesture into view
		self.addGestureRecognizer(self.swipeGestureLeft)
		self.addGestureRecognizer(self.swipeGestureRight)
		
		configure()
	}
	
	///	remove label by lable tag
	///	only call it when you use addSubview after reloadData()
	func removeLabel(tag: Int) {
		for sub in self.subviews {
			if sub.tag == tag {
				sub.removeFromSuperview()
			}
		}
	}
	
	///	remove all labels
	///	only call it when you use addSubview after reloadData()
	func removeLabel() {
		for subview in self.subviews {
			if subview is UILabel {
				subview.removeFromSuperview()
			}
		}
	}
	
	/// capture a screenshot for swipe transition between two views
	func capture() -> UIImageView {
		let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
		let image = renderer.image { ctx in
			self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
		}
		
		return UIImageView(image: image)
	}
	
	/// increase page number
	///	trigger animation from left to right
	@objc func handleSwipeLeft(_ gesture: UISwipeGestureRecognizer) {
		if self.pageControl.currentPage < numberOfCharts - 1 {
			self.pageControl.currentPage += 1
			currentChart = pageControl.currentPage
			
			//	capture a screenshot for trisition
			let imageView = self.capture()
			imageView.frame = self.frame
			superview?.addSubview(imageView)
			self.center.x += self.frame.width
			
			reloadData()
			UIView.animate(withDuration: 0.5, animations: {
				imageView.center.x -= self.frame.width
				self.center.x -= self.frame.width
			})
		} else { //
			UIView.animate(withDuration: 0.5, animations: {
				self.center.x -= 50
			}, completion: {(f) in
				self.center.x += 50
			})
		}
	}
	
	/// reduce page number
	///	trigger animation from right to left
	@objc func handleSwipeRight(_ gesture: UISwipeGestureRecognizer) {
		if self.pageControl.currentPage != 0 {
			self.pageControl.currentPage -= 1
			currentChart = pageControl.currentPage
			
			//	capture a screenshot for trisition
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
