//
//  HamsCoachMarkArea.swift
//  HamsterUIKit
//
//  Created by Drake on 6/25/17.
//  Copyright © 2017 Howard Wang. All rights reserved.
//

import Foundation
public enum HamsCoachMarkStyle {
	case navigation
	case tabbar
	case custom(CGRect)
}

public enum HamsMarkPosition {
	case custom(CGPoint)
	case auto
	case upSide
	case downSide
}

open class HamsCoachMarkArea {
	open var hightlightStyle: HamsCoachMarkStyle
	open var markPos: HamsMarkPosition
	open var backgroundColor: UIColor
	
	public init() {
		hightlightStyle = .navigation
		markPos = .auto
		backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.7)
		
	}
}
