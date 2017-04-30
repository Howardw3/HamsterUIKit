//
//  BarChartViewController.swift
//  HamsterUIKit
//
//  Created by Drake on 4/25/17.
//  Copyright © 2017 Howard Wang. All rights reserved.
//

import UIKit
import HamsterUIKit

class BarChartViewController: UIViewController, HamsBarChartDelegate, HamsBarChartDataSource {
	
	let dataSets:[CGFloat] = [10, 30, 60,20]
	let dataSets1:[[CGFloat]] = [[10,20,0],
	                           [28,48,39],
	                           [31,4,24],
	                           [42,45,13]]
	let redDark = UIColor(hue: 353/360, saturation: 73/100, brightness: 100/100, alpha: 1)
	let red = UIColor(hue: 345/360, saturation: 30/100, brightness: 100/100, alpha: 1)
	let blue = UIColor(hue: 216/360, saturation: 38/100, brightness: 83/100, alpha: 1)
	
	let barRed = UIColor(red: 0.89, green: 0, blue: 0.24, alpha: 1)
	let barBlue = UIColor(red: 0.35, green: 0.46, blue: 0.73, alpha: 1)
	let barGrey = UIColor(red: 0.69, green: 0.66, blue: 0.58, alpha: 1)
	let barYellow = UIColor(red: 0.88, green: 0.63, blue: 0.27, alpha: 1)
	let base = HamsChartBase()
	
	@IBOutlet weak var stackedBarChart: HamsBarChart!
	@IBOutlet weak var groupedBarChart: HamsBarChart!
	@IBOutlet weak var simpleBarChart: HamsBarChart!
    override func viewDidLoad() {
        super.viewDidLoad()
		
		simpleBarChart.delegate = self
		simpleBarChart.dataSource = self
		
		groupedBarChart.delegate = self
		groupedBarChart.dataSource = self
		
		stackedBarChart.delegate = self
		stackedBarChart.dataSource = self

		self.view.addSubview(simpleBarChart)
		self.view.addSubview(groupedBarChart)
		self.view.addSubview(stackedBarChart)
		
		_reloadData()
		
    }
	
	func _reloadData() {
		//load your data here
		
		simpleBarChart.reloadData()
		groupedBarChart.reloadData()
		stackedBarChart.reloadData()
	}
	
	func barChart(_ barChart: HamsBarChart, numberOfValuesInChart view: Int) -> Int {
		return dataSets.count
	}
	
	func numberOfCharts(in barChart: HamsBarChart) -> Int {
		if barChart == simpleBarChart {
			return 2
		}
		return 1
	}
	
	func barChart(_ barChart: HamsBarChart, barForChart indexPath: HamsIndexPath) -> HamsBarChartRect {
		let rect = HamsBarChartRect()
		
		if barChart == simpleBarChart {
			switch indexPath.chart {
			case 0:
				rect.value = .plain(dataSets[indexPath.column])
				rect.color = .plain(.white)
			case 1:
				rect.value = .plain(dataSets[indexPath.column])
				rect.color = .randomed([barRed, barBlue, barGrey, .white])
			default: break
			}
			
		}
		
		if barChart == groupedBarChart {
			rect.value = .grouped(dataSets1[indexPath.column])
			rect.color = .arranged([barRed, barBlue, barGrey])
		}
		
		if barChart == stackedBarChart {
			rect.value = .stacked(dataSets1[indexPath.column])
			rect.color = .arranged([barRed, barBlue, barGrey])
		}

		return rect
	}
	
	func barChart(_ barChart: HamsBarChart, configureForCharts view: Int) {
		
		if barChart == simpleBarChart {
			
			simpleBarChart.filledStyle = .plain(blue)
			simpleBarChart.labelStyle = .custom(["session1","session2","session3", "session4"])
			if view == 0 {
				simpleBarChart.title = "BarChart(plain)"
				simpleBarChart.offsets = ChartOffset(top: 20, bottom: 0, column: 30, horizon: 20)
			} else {
				simpleBarChart.title = "BarChart(random color)"
			}
		}
		if barChart == groupedBarChart{
			groupedBarChart.title = "Grouped BarChart"
			groupedBarChart.filledStyle = .gradient(top: redDark, bottom: red)
			groupedBarChart.labelStyle = .custom(["1st sy","2nd sy","3rd sy", "4th sy"])
		}
		if barChart == stackedBarChart{
			stackedBarChart.title = "Stacked BarChart"
			stackedBarChart.filledStyle = .gradient(top: redDark, bottom: red)
			stackedBarChart.offsets = ChartOffset(top: 0, bottom: 0, column: 30, horizon: 20)
		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    

}
