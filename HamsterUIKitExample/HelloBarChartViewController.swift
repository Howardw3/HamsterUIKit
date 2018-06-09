//
//  HelloBarChartViewController.swift
//  HamsterUIKit
//
//  Created by Drake on 4/30/17.
//  Copyright © 2017 Howard Wang. All rights reserved.
//

import UIKit
import HamsterUIKit

class HelloBarChartViewController: UIViewController, HamsBarChartDelegate, HamsBarChartDataSource {
	var barChart: HamsBarChart = HamsBarChart()
	var dataSets = [CGFloat]()
    override func viewDidLoad() {
        super.viewDidLoad()
		barChart = HamsBarChart(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))

		barChart.delegate = self
		barChart.dataSource = self
		view.addSubview(barChart)
    }

	func barChart(_ barChart: HamsBarChart, numberOfValuesInChart chart: Int) -> Int {
		return dataSets.count
	}

	func numberOfCharts(in barChart: HamsBarChart) -> Int {
		return 1
	}

	func barChart(_ barChart: HamsBarChart, barForChart indexPath: HamsIndexPath) -> HamsBarChartRect {
		let rect = HamsBarChartRect()
		rect.value = .plain(dataSets[indexPath.column])
		rect.color = .plain(.white)
		return rect
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		dataSets = [1, 4, 6, 1]
		barChart.reloadData()
	}

	func barChart(_ barChart: HamsBarChart, configureForCharts view: Int) {

		barChart.title = "BarChart(plain)"
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
