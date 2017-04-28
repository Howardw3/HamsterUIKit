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
	
	var simpleBarChart:HamsBarChart!
	var groupedBarChart:HamsBarChart!
	var stackedBarChart: HamsBarChart!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		simpleBarChart = HamsBarChart(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width/2))
		groupedBarChart = HamsBarChart(frame: CGRect(x: 0, y: view.frame.width/2 + 40, width: view.frame.width, height: view.frame.width/2))
		stackedBarChart = HamsBarChart(frame: CGRect(x: 0, y: view.frame.width/2*2 + 40*2, width: view.frame.width, height: view.frame.width/2))
		
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
	
	func barChart(_ barChart: HamsBarChart, numberOfPointsInView view: Int) -> Int {
		return dataSets.count
	}
	
	func numberOfViews(in barChart: HamsBarChart) -> Int {
		if barChart == simpleBarChart {
			return 2
		}
		return 1
	}
	
	func barChart(_ barChart: HamsBarChart, barForChart indexPath: HamsIndexPath) -> HamsBarChartRect {
		let rect = HamsBarChartRect()
		
		if barChart == simpleBarChart {
			switch indexPath.view {
			case 0:
				rect.value = .plain(dataSets[indexPath.column])
				rect.color = .plain(.white)
			case 1:
				rect.value = .plain(dataSets[indexPath.column])
				rect.color = .randomed([.red, .white, .cyan, .black])
			default: break
			}
			
		}
		
		if barChart == groupedBarChart {
			rect.value = .stacked(dataSets1[indexPath.column])
			rect.color = .arranged([barRed, barBlue, barGrey])
		}
		
		if barChart == stackedBarChart {
			rect.value = .grouped(dataSets1[indexPath.column])
			rect.color = .arranged([barRed, barBlue, barGrey])
		}

		return rect
	}
	
	func barChart(_ barChart: HamsBarChart, configureForViews view: Int) {
		simpleBarChart.offsets = ChartOffset(top: 0, bottom: 0, column: 30, horizon: 50)
		groupedBarChart.offsets = ChartOffset(top: 0, bottom: 0, column: 30, horizon: 50)
		stackedBarChart.offsets = ChartOffset(top: 0, bottom: 0, column: 30, horizon: 50)
		
		if barChart == simpleBarChart {
			simpleBarChart.filledColor = .plain(blue)
			simpleBarChart.labelStyle = .custom(["session1","session2","session3"])
		}
		if barChart == groupedBarChart{
			groupedBarChart.filledColor = .gradient(top: redDark, bottom: red)
			groupedBarChart.labelStyle = .custom(["1st sy","2nd sy","3rd sy"])
		}
		if barChart == stackedBarChart{
			stackedBarChart.filledColor = .gradient(top: redDark, bottom: red)
		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    

}
