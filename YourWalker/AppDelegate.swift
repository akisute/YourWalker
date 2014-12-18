//
//  AppDelegate.swift
//  YourWalker
//
//  Created by 小野 将司 on 2014/10/20.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        Fabric.with([Crashlytics()])
        
        let settings = UIUserNotificationSettings(forTypes: .Badge, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        HealthStore.sharedInstance.startStepCountBackgroundUpdate()
        HealthStore.sharedInstance.setStepCountBackgroundUpdateHandler({[unowned self] complete, error in
            if error != nil {
                self.startUpdatingBadgeCount().then({_, errorInfo in
                    complete()
                })
            } else {
                complete()
            }
        })
        
        NSLog("test test")
        NSLog("test test")
        NSLog("test test")
        NSLog("test test")
        NSLog("test test")
        let logs = ASL().filter(seconds: 24*60*60).limit(3).readlines()
        NSLog("%@", logs.description)
        
        return true
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        let identifier = application.beginBackgroundTaskWithExpirationHandler({})
        self.startUpdatingBadgeCount().then({_, errorInfo in
            application.endBackgroundTask(identifier)
        })
    }
    
    private func startUpdatingBadgeCount() -> HealthStoreTask {
        return HealthStore.sharedInstance.findStepCountCumulativeSumToGoalToday().success({(stepCountToGoal: Int) -> Void in
            UIApplication.sharedApplication().applicationIconBadgeNumber = stepCountToGoal
        })
    }
}

