//
//  HamsIndexPath.swift
//  HamsterUIKit
//
//  Created by Howard on 4/23/17.
//  Copyright © 2017 Howard Wang. All rights reserved.
//

import Foundation
open class HamsIndexPath {
	fileprivate var _point = 0
	fileprivate var _view = 0
	public init(point: Int, view: Int) {
		_point = point
		_view = view
	}
	
	open var point: Int { return _point }
	open var view: Int { return _view }
}
