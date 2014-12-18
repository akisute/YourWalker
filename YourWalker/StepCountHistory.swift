//
//  StepCountHistory.swift
//  YourWalker
//
//  Created by 小野 将司 on 2014/11/03.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

import UIKit
import HealthKit

class StepCountHistory {
    let stepCount: Int = 0
    let startDate: NSDate?
    let endDate: NSDate?
    
    init?(statistics: HKStatistics) {
        if let sum = statistics.sumQuantity() {
            self.stepCount = Int(sum.doubleValueForUnit(HKUnit.countUnit()))
            self.startDate = statistics.startDate
            self.endDate = statistics.endDate
        } else {
            return nil
        }
    }
    
    var displayDate: NSDate {
        get {
            if let d = self.startDate {
                return d;
            } else if let d = self.endDate {
                return d;
            } else {
                return NSDate()
            }
        }
    }
}
