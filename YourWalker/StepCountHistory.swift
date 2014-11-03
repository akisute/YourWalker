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
    let stepCount: Int
    let startDate: NSDate
    let endDate: NSDate
    
    init(statistics: HKStatistics) {
        self.stepCount = Int(statistics.sumQuantity().doubleValueForUnit(HKUnit.countUnit()))
        self.startDate = statistics.startDate
        self.endDate = statistics.endDate
    }
}
