//
//  HamsIndexPath.swift
//  HamsterUIKit
//
//  Created by Howard on 4/23/17.
//  Copyright © 2017 Howard Wang. All rights reserved.
//

import Foundation
open class HamsIndexPath {
	fileprivate var _column = 0
	fileprivate var _view = 0
	public init(column: Int, view: Int) {
		_column = column
		_view = view
	}
	
	open var column: Int { return _column }
	open var view: Int { return _view }
}
