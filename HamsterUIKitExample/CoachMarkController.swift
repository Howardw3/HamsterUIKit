//
//  CoachMarkController.swift
//  HamsterUIKit
//
//  Created by Drake on 6/18/17.
//  Copyright © 2017 Howard Wang. All rights reserved.
//

import UIKit
import HamsterUIKit
class CoachMarkController: UIViewController, HamsCoachMarkDataSource {

	func numberOfMarks(in coachMark: HamsCoachMark) -> Int {
		return 5
	}

	
	func coachMark(_ coachMark: HamsCoachMark, stepForCoachMark step: Int) -> HamsCoachMarkArea {
		let coachMarkArea = HamsCoachMarkArea()
		
		switch step {
		case 0:
			coachMarkArea.hightlightStyle = .navigation
		case 1:
			coachMarkArea.hightlightStyle = .tabbar
		case 2:
			coachMarkArea.hightlightStyle = .custom(CGRect(x: 0, y: 200, width: view.frame.width, height: 200))
		case 3:
			coachMarkArea.hightlightStyle = .tabbar
		case 4:
			coachMarkArea.hightlightStyle = .navigation
		default: break
		
		
		}
		return coachMarkArea
	}


    override func viewDidLoad() {
        super.viewDidLoad()
		let coachMark = HamsCoachMark(frame: view.frame)
		coachMark.ctr = self
		coachMark.dataSource = self

		view.addSubview(coachMark)
//		debugPrint(navigationController?.navigationBar.frame, tabBarController?.tabBar.frame)
        // Do any additional setup after loading the view.
    }
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
