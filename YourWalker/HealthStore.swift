//
//  HealthStore.swift
//  YourWalker
//
//  Created by 小野 将司 on 2014/10/20.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

import UIKit
import HealthKit
import SwiftTask

typealias HealthStoreBoolTask = Task<Void, Bool, NSError>
typealias HealthStoreCountTask = Task<Void, Int, NSError>

class HealthStore: NSObject {
    
    let store: HKHealthStore = HKHealthStore()
    
    class var sharedInstance : HealthStore {
        struct Static {
            static let instance : HealthStore = HealthStore()
        }
        return Static.instance
    }
   
    func findStepCountCumulativeSumToday() -> HealthStoreCountTask {
        let requestAuthorizationTask = HealthStoreBoolTask(initClosure: { progress, fulfill, reject, configure in
            let stepCountType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
            let writeTypes = NSSet(array: [])
            let readTypes = NSSet(array: [stepCountType])
            
            self.store.requestAuthorizationToShareTypes(writeTypes, readTypes: readTypes) {success, error in
                if error != nil {
                    reject(error)
                    return
                }
                fulfill(success)
                return
            }
        })
        
        let executeQueryTask = HealthStoreCountTask(initClosure: { progress, fulfill, reject, configure in
            let calendar = NSCalendar.currentCalendar()
            let now = NSDate()
            let components = calendar.components(.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit, fromDate: now)
            let startDate = calendar.dateFromComponents(components)!
            let endDate = calendar.dateByAddingUnit(.DayCalendarUnit, value: 1, toDate: startDate, options: nil)
            
            let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .StrictStartDate)
            let sampleType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
            
            let query = HKStatisticsQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: .CumulativeSum) { query, result, error in
                if error != nil {
                    reject(error)
                    return
                }
                
                var totalStepCounts = 0.0
                if let quantity = result.sumQuantity() {
                    let unit = HKUnit.countUnit()
                    totalStepCounts = quantity.doubleValueForUnit(unit)
                }
                fulfill(Int(totalStepCounts))
                return
            }
            /*
            let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 0, sortDescriptors: nil, resultsHandler: {query, results, error in
                if error != nil {
                    reject(error)
                    return
                }
                
                var totalStepCounts = 0.0
                for result in results {
                    if let quantitySample: HKQuantitySample = result as? HKQuantitySample {
                        totalStepCounts += quantitySample.quantity.doubleValueForUnit(HKUnit.countUnit())
                    }
                }
                fulfill(Int(totalStepCounts))
                return
            })
            */
            self.store.executeQuery(query)
        })
        
        return requestAuthorizationTask.then({(succeeded: Bool) -> HealthStoreCountTask in
            return executeQueryTask
        })
    }
}
