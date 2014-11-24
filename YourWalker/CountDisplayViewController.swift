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
    @IBOutlet var stepCountDescriptionLabel: UILabel!
    @IBOutlet var stepCountLoadingActivityIndicator: UIActivityIndicatorView!
    
    let healthStore = HKHealthStore()
    let numberFormatter = NSNumberFormatter()
    var currentStepCount: Int = -1
    
    class func instantiateFromStoryboard() -> UIViewController {
        let storyboard = UIStoryboard(name: "CountDisplayViewController", bundle: nil)
        return storyboard.instantiateInitialViewController() as UIViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.numberFormatter.locale = NSLocale(localeIdentifier: "en_US")
        self.numberFormatter.numberStyle = .DecimalStyle
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateStepCountLabels(loading: true)
        HealthStore.sharedInstance.findStepCountCumulativeSumToday().success({[unowned self] (stepCount: Int) -> Void in
            self.currentStepCount = stepCount
            dispatch_async(dispatch_get_main_queue(), {
                self.updateStepCountLabels(loading: false)
            })
        }).failure({[unowned self] (error: NSError?, isCancelled: Bool) -> Void in
            if let e = error {
                NSLog("%@", e)
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.updateStepCountLabels(loading: false)
            })
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func updateStepCountLabels(#loading: Bool) {
        if (self.currentStepCount < 0) {
            self.stepCountLabel.text = ""
            self.stepCountLabel.hidden = true
            self.stepCountDescriptionLabel.hidden = true
            if (loading) {
                self.stepCountLoadingActivityIndicator.startAnimating()
            } else {
                self.stepCountLoadingActivityIndicator.stopAnimating()
            }
        } else {
            let text = self.numberFormatter.stringFromNumber(10000 - self.currentStepCount)
            self.stepCountLabel.text = text
            self.stepCountLabel.hidden = false
            self.stepCountDescriptionLabel.hidden = false
            self.stepCountLoadingActivityIndicator.stopAnimating()
        }
    }
}
