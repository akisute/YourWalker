//
//  HistoryDisplayViewController.swift
//  YourWalker
//
//  Created by 小野 将司 on 2014/11/03.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

import UIKit

class HistoryDisplayViewController: UITableViewController {
    
    class func instantiateFromStoryboard() -> UIViewController {
        let storyboard = UIStoryboard(name: "HistoryDisplayViewController", bundle: nil)
        return storyboard.instantiateInitialViewController() as UIViewController
    }
    
}
