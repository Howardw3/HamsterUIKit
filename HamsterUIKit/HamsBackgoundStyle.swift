//
//  HamsBackgoundStyle.swift
//  HamsterUIKit
//
//  Created by Howard on 4/23/17.
//  Copyright © 2017 Howard Wang. All rights reserved.
//

import Foundation

public enum HamsBackgoundStyle {
	case plain(UIColor) // single color
	case gradient(top: UIColor,bottom: UIColor) // from top to bottom
}
