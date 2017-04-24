//: Playground - noun: a place where people can play

import UIKit
import HamsterUIKit

class HamsController:UIViewController, HamsCurveChartDelegate, HamsCurveChartDataSource {
	let redDark = UIColor(hue: 353/360, saturation: 73/100, brightness: 100/100, alpha: 1)
	let red = UIColor(hue: 345/360, saturation: 30/100, brightness: 100/100, alpha: 1)
	let blue = UIColor(hue: 216/360, saturation: 38/100, brightness: 83/100, alpha: 1)
	
	let dataSets = [[20, 3000, 100, 20,222,1000,0,92,40],
	                [0, 60, 20, 0],
	                [30, 60, 1, 0],
	                [0, 0, 0, 0]]
	
	var hamsCurveChart = HamsCurveChart(frame: CGRect(origin: CGPoint(x:0, y: 50), size: CGSize(width: 375, height: 200)))
	
	override func viewDidLoad() {
		super.viewDidLoad()
//		hamsCurveChart = HamsCurveChart(frame: view.frame)
		hamsCurveChart.offsets = ChartOffset(top: 65, bottom: 60, column: 0, horizon: 0)
		hamsCurveChart.delegate = self
		hamsCurveChart.dataSource = self
		self.view.addSubview(hamsCurveChart)
		_reloadData()
	}
	
	func _reloadData() {
		//load your data here
		
		hamsCurveChart.reloadData()
	}
	
	func curveChart(_ curveChart: HamsCurveChart, configureForViews view: Int) {
		switch view {
		case 0:
			hamsCurveChart.filledColor = .gradient(top: redDark, bottom: red)
			hamsCurveChart.startPoint = .zero
			hamsCurveChart.suggestValue = 900
		case 1:
			
			hamsCurveChart.filledColor = .plain(blue)
			hamsCurveChart.maxValue = 50
			hamsCurveChart.pageIndicatorTintColor = UIColor(hue: 336, saturation: 19, brightness: 100, alpha: 1)
		case 2:
			hamsCurveChart.filledColor = .plain(redDark)
			hamsCurveChart.suggestValue = 100
		case 3: break
		default:break
		}
	}
	
	func curveChart(_ curveChart: HamsCurveChart, pointForChart indexPath: HamsIndexPath) -> HamsCurveChartPoint {
		let point = HamsCurveChartPoint()
		
		switch indexPath.view {
		case 0:
			point.innerColor = blue
			point.pointValue = CGFloat(dataSets[indexPath.view][indexPath.point])
		case 1:
			point.innerColor = redDark
			point.pointValue = CGFloat(dataSets[indexPath.view][indexPath.point])
			
		case 2:
			point.pointValue = CGFloat(dataSets[indexPath.view][indexPath.point])
		case 3:
			point.pointValue = CGFloat(dataSets[indexPath.view][indexPath.point])
		default:break
		}
		return point
	}
	
	func curveChart(_ curveChart: HamsCurveChart, numberOfPointsInView view: Int) -> Int {
		return dataSets[view].count
	}
	func numberOfViews(in tableView: HamsCurveChart) -> Int {
		return 4
	}
}

