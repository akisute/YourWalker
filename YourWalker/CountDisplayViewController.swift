//
//  CountDisplayViewController.swift
//  YourWalker
//
//  Created by 小野 将司 on 2014/10/20.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

import UIKit
import HealthKit

class CountDisplayViewController: UIViewController {
    
    @IBOutlet var stepCountLabel: UILabel!
    
    let healthStore = HKHealthStore()
    let numberFormatter = NSNumberFormatter()
    
    class func instantiateFromNib() -> CountDisplayViewController {
        let storyboard = UIStoryboard(name: "CountDisplayViewController", bundle: nil)
        return storyboard.instantiateInitialViewController() as CountDisplayViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.numberFormatter.locale = NSLocale(localeIdentifier: "en_US")
        self.numberFormatter.numberStyle = .DecimalStyle
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        HealthStore.sharedInstance.findStepCountCumulativeSumToday().then({[unowned self] (stepCount: Int) -> Void in
            let text = self.numberFormatter.stringFromNumber(10000 - stepCount)
            dispatch_async(dispatch_get_main_queue(), {
                self.stepCountLabel.text = text
            })
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

}
