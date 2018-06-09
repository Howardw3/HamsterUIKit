//
//  Extension.swift
//  HamsterUIKit
//
//  Created by Drake on 4/16/17.
//  Copyright © 2017 Howard Wang. All rights reserved.
//

import Foundation

protocol UIViewExtention {
	func roundCorners(corners: UIRectCorner, radius: CGFloat)
}

extension UIView: UIViewExtention {
	func roundCorners(corners: UIRectCorner, radius: CGFloat) {
		let mask = CAShapeLayer()
		mask.path = UIBezierPath(roundedRect: self.bounds,
                                 byRoundingCorners: corners,
                                 cornerRadii: CGSize(width: radius, height: radius)).cgPath
		self.layer.mask = mask
	}
}
