//
//  RootViewController.swift
//  YourWalker
//
//  Created by 小野 将司 on 2014/10/20.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var countDisplayContainer: UIView!
    @IBOutlet var historyDisplayContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let countDisplayViewController = CountDisplayViewController.instantiateFromNib()
        self.addChildViewController(countDisplayViewController)
        countDisplayViewController.didMoveToParentViewController(self)
        countDisplayViewController.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.countDisplayContainer.addSubview(countDisplayViewController.view)
        self.countDisplayContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: nil, metrics: nil, views: ["view": countDisplayViewController.view]))
        self.countDisplayContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: nil, metrics: nil, views: ["view": countDisplayViewController.view]))
    }

}
