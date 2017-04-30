//
//  HamsIndexPath.swift
//  HamsterUIKit
//
//  Created by Howard on 4/23/17.
//  Copyright © 2017 Howard Wang. All rights reserved.
//

import Foundation

///	same as IndexPath in UITableVIew, it contains two value
///	column: index of data in data set
///	chart: index of chart
open class HamsIndexPath {
	fileprivate var _column = 0
	fileprivate var _chart = 0
	
	///	method to create a HamsIndexPath
	public init(column: Int, view: Int) {
		_column = column
		_chart = chart
	}
	
	open var column: Int { return _column }
	open var chart: Int { return _chart }
}
