//
//  HistoryDisplayViewController.swift
//  YourWalker
//
//  Created by 小野 将司 on 2014/11/03.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

import UIKit

class HistoryDisplayViewController: UITableViewController {
    
    var histories: [StepCountHistory]?
    
    class func instantiateFromStoryboard() -> UIViewController {
        let storyboard = UIStoryboard(name: "HistoryDisplayViewController", bundle: nil)
        return storyboard.instantiateInitialViewController() as UIViewController
    }
    
    override func viewWillAppear(animated: Bool) {
        let loadingTask: HealthStoreStepCountHistoryListTask = HealthStore.sharedInstance.findStepCountHistory()
        loadingTask.then({[unowned self](results: [StepCountHistory]) -> (Void) in
            dispatch_async(dispatch_get_main_queue(), {
                self.histories = results
                self.tableView.reloadData()
            })
        })
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        if let history = self.stepCountHistoryForIndexPath(indexPath) {
            cell.textLabel.text = "\(history.stepCount)"
        }
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
}
