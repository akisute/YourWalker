//
//  HistoryDisplayViewController.swift
//  YourWalker
//
//  Created by 小野 将司 on 2014/11/03.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

import UIKit

class HistoryDisplayViewController: UITableViewController {
    
    private var histories: [StepCountHistory]?
    
    class func instantiateFromStoryboard() -> UIViewController {
        let storyboard = UIStoryboard(name: "HistoryDisplayViewController", bundle: nil)
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
    
    // MARK: - UITableViewDelegate/DataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let histories = self.histories {
            return histories.count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as HistoryDisplayViewCell
        cell.stepCountHistory = self.stepCountHistoryForIndexPath(indexPath)
        return cell
    }
    
    // MARK: - Private
    
    private func stepCountHistoryForIndexPath(indexPath: NSIndexPath) -> StepCountHistory? {
        if let histories = self.histories {
            return histories[indexPath.row]
        } else {
            return nil
        }
    }
    
    private func loadStepCount() {
        HealthStore.sharedInstance.findStepCountHistory().success({[unowned self] (results: [StepCountHistory]) -> (Void) in
            dispatch_async(dispatch_get_main_queue(), {
                self.histories = results
                self.tableView.reloadData()
            })
        })
    }
}
