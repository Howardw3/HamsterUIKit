//
//  QuadCurvedAlgorithm.swift
//  HamsterUIKit
//
//  Created by Howard on 2/11/17.
//  Copyright © 2017 Howard Wang. All rights reserved.
//

import Foundation
import UIKit

open class QuadCurveAlgorithm: ChartsCore {
	
	fileprivate lazy var count = 0
	
	public override init(with points: [CGFloat], frameSize:CGSize, offsets: ChartOffset) {
		super.init(with: points, frameSize: frameSize, offsets: offsets)
		count = points.count
	}
	
	public convenience init(frameSize: CGSize, offsets: ChartOffset) {
		self.init(with: [], frameSize: frameSize, offsets: offsets)
	}
	open var quadCurvePath: UIBezierPath {
		let graphPath = UIBezierPath()
		var p1 = getPoint(by: 0)
		graphPath.move(to: p1)
		if count == 2 {
			let p2 = getPoint(by: 1)
			graphPath.addLine(to: p2)
			return graphPath
		}
		
		for i in 1..<count {
			let p2 = getPoint(by: i)
			let midPoint = midPointForPoints(p1: p1, p2: p2)
			graphPath.addQuadCurve(to: midPoint, controlPoint: controlPointForPoints(p1: midPoint, p2: p1))
			graphPath.addQuadCurve(to: p2, controlPoint: controlPointForPoints(p1: midPoint, p2: p2))
			p1 = p2
			
		}
		
		return graphPath
	}
	
	open var quadWavePath: UIBezierPath {
		let graphPath = UIBezierPath()
		let p1 = getPoint(by: 0)
		graphPath.move(to: p1)
		if count == 2 {
			let p2 = getPoint(by: 1)
			graphPath.addLine(to: p2)
			return graphPath
		}
		
		for i in 1..<count {
			let p2 = getPoint(by: i)
			
			let controlPoint = getPoint(by: i-1)
			if i % 2 == 0 {
				graphPath.addQuadCurve(to: p2, controlPoint: controlPoint)
			}
		}
		
		return graphPath
	}
	
	fileprivate func midPointForPoints(p1:CGPoint, p2:CGPoint) -> CGPoint{
		return CGPoint(x:(p1.x + p2.x) / 2, y:(p1.y + p2.y) / 2)
	}
	
	fileprivate func controlPointForPoints(p1:CGPoint, p2:CGPoint) -> CGPoint {
		var controlPoint:CGPoint = midPointForPoints(p1: p1, p2: p2)
		let diffY:CGFloat = abs(p2.y - controlPoint.y)
		
		if p1.y < p2.y {
			controlPoint.y += diffY}
		else if p1.y > p2.y {
			controlPoint.y -= diffY}
		
		return controlPoint
	}
}
