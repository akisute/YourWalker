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

class DebugShakeWindow: UIWindow {
    
    var shaking: Bool = false
    weak var presentingDebugViewController: UIViewController?
    
    var shouldPresentDebugViewController: Bool {
        get {
            return self.shaking && UIApplication.sharedApplication().applicationState == .Active;
        }
    }
    
    func presentDebugViewController() {
        var visibleViewController = self.rootViewController
        while (visibleViewController?.presentedViewController != nil) {
            visibleViewController = visibleViewController?.presentedViewController
        }
        
        // Prevent double-presenting the view controller.
        if self.presentingDebugViewController == nil {
            let viewController = ASLViewController()
            visibleViewController?.presentViewController(viewController, animated: true, completion:nil)
            self.presentingDebugViewController = viewController
        }
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == .MotionShake {
            self.shaking = true
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(400 * NSEC_PER_MSEC)), dispatch_get_main_queue(), {
                if (self.shouldPresentDebugViewController) {
                    self.presentDebugViewController()
                }
            });
        }
        super.motionBegan(motion, withEvent: event)
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == .MotionShake {
            self.shaking = false
        }
        super.motionEnded(motion, withEvent: event)
    }
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var window: UIWindow = {
        return DebugShakeWindow(frame: UIScreen.mainScreen().bounds)
    }()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        Fabric.with([Crashlytics()])
        
        DDLog.addLogger(DDASLLogger.sharedInstance()) // to /var/log of the device. Can view from Xcode Organizer.
        DDLog.addLogger(DDTTYLogger.sharedInstance()) // to Terminal of Xcode.
        let fileLogger = DDFileLogger()               // to ~/Library/Caches of the device.
        fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        DDLog.addLogger(fileLogger)
        
        defaultDebugLevel = DDLogLevel.Debug
        DDLogInfo("Hello, CocoaLumberjack!")
        DDLogDebug("Current time is: %@", args: NSDate())
        
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

