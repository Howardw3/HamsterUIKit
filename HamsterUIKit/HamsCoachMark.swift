//
//  HamsCoachMark.swift
//  HamsterUIKit
//
//  Created by Drake on 6/18/17.
//  Copyright © 2017 Howard Wang. All rights reserved.
//

import UIKit

public protocol HamsCoachMarkDataSource{
	///	implement this method to customize value point
	func coachMark(_ coachMark: HamsCoachMark, stepForCoachMark step: Int) -> HamsCoachMarkArea
	
	///	set number of charts
	func numberOfMarks(in coachMark: HamsCoachMark) -> Int
}

open class HamsCoachMark: UIView {
	
	open var ctr = UIViewController()
	open var coachMarkStyle = HamsCoachMarkStyle.navigation
	open var view = UIView()
	open var dataSource: HamsCoachMarkDataSource?
	
	fileprivate var currectStep: Int = 0
	fileprivate var base = UIView()
	fileprivate var overlapView = UIView()
	fileprivate var touchedPoint:CGPoint = CGPoint.zero
	
	override public init(frame: CGRect) {
		super.init(frame: frame)
		

		self.backgroundColor = .clear
		
		base = UIView(frame: frame)
//		let currentWindow = UIApplication.shared.keyWindow
//		currentWindow?.addSubview(base)
		
		
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	
	override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			currectStep += 1
			debugPrint("click", currectStep)
			touchedPoint = touch.location(in: self)
			setNeedsDisplay()
		}

	}
	var popupWindow: UIWindow?
	
	func showViewController(controller: UIViewController) {
		self.popupWindow = UIWindow(frame: UIScreen.main.bounds)
		
		controller.view.frame = self.popupWindow!.bounds
		self.popupWindow!.rootViewController = controller
		self.popupWindow!.makeKeyAndVisible()
	}
	
	func viewControllerDidRemove() {
		self.popupWindow?.removeFromSuperview()
		self.popupWindow = nil
	}
	
	open var numberOfCharts: Int {
		return dataSource!.numberOfMarks(in: self)
	}
	
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override open func draw(_ rect: CGRect) {

		
		guard let coachMarkArea = dataSource?.coachMark(self, stepForCoachMark: currectStep) else {
			debugPrint("enreal")
			return
		}
	
		
		let statusHeight = UIApplication.shared.statusBarFrame.height
		let navFrame = ctr.navigationController?.navigationBar.frame
		ctr.navigationController?.navigationBar.subviews.forEach {
			if $0.tag == 1200 { $0.removeFromSuperview()} }
		
		switch coachMarkArea.hightlightStyle {
		case .navigation:
			
			
			overlapView = UIView(frame: CGRect(x: 0,
			                                       y: (navFrame?.height)!+statusHeight,
			                                       width: (navFrame?.width)!,
			                                       height: base.frame.height - (navFrame?.height)! - statusHeight))
			
		case .custom(let rect):
            debugPrint(navFrame!)
			let overNavView = UIView(frame: CGRect(x: 0, y: 0, width: (navFrame?.width)!, height: (navFrame?.height)!))
			overNavView.backgroundColor = coachMarkArea.backgroundColor
			overNavView.tag = 1200
			ctr.navigationController?.navigationBar.addSubview(overNavView)
			overlapView = UIView(frame: rect)
		default:
			showViewController(controller: ctr)
			break
		}
		base.subviews.forEach { $0.removeFromSuperview() }
		overlapView.backgroundColor = coachMarkArea.backgroundColor
		base.addSubview(overlapView)
//		let currentWindow = UIApplication.shared.keyWindow
//		currentWindow?.addSubview(base)
		self.addSubview(base)
		debugPrint(coachMarkArea.hightlightStyle)
//		debugPrint(ctr.navigationController?.navigationBar.frame,ctr.tabBarController?.tabBar.frame)
		
    }
	
	
}


