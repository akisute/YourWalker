//
//  RootViewController.swift
//  YourWalker
//
//  Created by 小野 将司 on 2014/10/20.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = CountDisplayViewController.instantiateFromNib()
        self.addChildViewController(vc)
        vc.didMoveToParentViewController(self)
        self.view.addSubview(vc.view)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: nil, metrics: nil, views: ["view": vc.view]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: nil, metrics: nil, views: ["view": vc.view]))
    }

}
