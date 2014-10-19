//
//  CountDisplayViewController.swift
//  YourWalker
//
//  Created by 小野 将司 on 2014/10/20.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

import UIKit

class CountDisplayViewController: UIViewController {
    
    class func instantiateFromNib() -> CountDisplayViewController {
        let storyboard = UIStoryboard(name: "CountDisplayViewController", bundle: nil)
        return storyboard.instantiateInitialViewController() as CountDisplayViewController
    }

}
