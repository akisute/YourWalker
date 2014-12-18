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
        
        HealthStore.sharedInstance.startStepCountBackgroundUpdate().success({[unowned self] () -> () in
            NSLog("HealthStore.sharedInstance.startStepCountBackgroundUpdate().success()")
            HealthStore.sharedInstance.setStepCountBackgroundUpdateHandler({complete, error in
                if let e = error {
                    NSLog("stepCountBackgroundUpdateHandler(error: %@)", e)
                    complete()
                } else {
                    NSLog("stepCountBackgroundUpdateHandler()")
                    self.startUpdatingBadgeCount().then({_, errorInfo in
                        complete()
                    })
                }
            })
        })
        
        return true
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        NSLog("%@.%@", reflect(self).summary, __FUNCTION__)
        let identifier = application.beginBackgroundTaskWithExpirationHandler({})
        self.startUpdatingBadgeCount().then({_, errorInfo in
            application.endBackgroundTask(identifier)
        })
    }
    
    private func startUpdatingBadgeCount() -> HealthStoreTask {
        NSLog("%@.%@", reflect(self).summary, __FUNCTION__)
        return HealthStore.sharedInstance.findStepCountCumulativeSumToGoalToday().success({(stepCountToGoal: Int) -> Void in
            NSLog("HealthStore.sharedInstance.findStepCountCumulativeSumToGoalToday().success()")
            UIApplication.sharedApplication().applicationIconBadgeNumber = stepCountToGoal
        })
    }
}

