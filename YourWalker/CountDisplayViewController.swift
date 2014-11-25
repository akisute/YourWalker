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
    
    private var currentStepCountToGoal: Int = NSNotFound
    
    class func instantiateFromStoryboard() -> UIViewController {
        let storyboard = UIStoryboard(name: "CountDisplayViewController", bundle: nil)
        return storyboard.instantiateInitialViewController() as UIViewController
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadStepCount()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"onApplicationWillEnterForegroundNotification", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func onApplicationWillEnterForegroundNotification() {
        self.loadStepCount()
    }
    
    // MARK: - Private

    private func updateStepCountLabels(#loading: Bool) {
        if (self.currentStepCountToGoal == NSNotFound) {
            self.stepCountLabel.text = ""
            self.stepCountLabel.hidden = true
            self.stepCountDescriptionLabel.hidden = true
            if (loading) {
                self.stepCountLoadingActivityIndicator.startAnimating()
            } else {
                self.stepCountLoadingActivityIndicator.stopAnimating()
            }
        } else {
            let text = FormatterManager.sharedInstance.numberFormatter_Decimal.stringFromNumber(self.currentStepCountToGoal)
            self.stepCountLabel.text = text
            self.stepCountLabel.hidden = false
            self.stepCountDescriptionLabel.hidden = false
            self.stepCountLoadingActivityIndicator.stopAnimating()
        }
    }
    
    private func loadStepCount() {
        self.updateStepCountLabels(loading: true)
        HealthStore.sharedInstance.findStepCountCumulativeSumToGoalToday().success({[unowned self] (stepCountToGoal: Int) -> Void in
            self.currentStepCountToGoal = stepCountToGoal
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
}
