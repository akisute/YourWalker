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
typealias HealthStoreStepCountHistoryTask = Task<Void, StepCountHistory, NSError>
typealias HealthStoreStepCountHistoryListTask = Task<Void, [StepCountHistory], NSError>

class HealthStore {
    
    let store: HKHealthStore = HKHealthStore()
    
    class var sharedInstance : HealthStore {
        struct Static {
            static let instance : HealthStore = HealthStore()
        }
        return Static.instance
    }
    
    private var requestAuthorizationTask: HealthStoreBoolTask {
        get {
            return HealthStoreBoolTask(initClosure: { progress, fulfill, reject, configure in
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
        }
    }
   
    func findStepCountCumulativeSumToday() -> HealthStoreCountTask {
        let executeQueryTask = HealthStoreCountTask(initClosure: { progress, fulfill, reject, configure in
            let calendar = NSCalendar.currentCalendar()
            let now = NSDate()
            let nowComponents = calendar.components(.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit, fromDate: now)
            let startDate = calendar.dateFromComponents(nowComponents)!
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
        
        return self.requestAuthorizationTask.then({(succeeded: Bool) -> HealthStoreCountTask in
            return executeQueryTask
        })
    }
    
    func findStepCountHistory(dates: Int = 14) -> HealthStoreStepCountHistoryListTask {
        let authenticationTask: Task<Void, Bool, NSError> = Task<Void, Bool, NSError>(initClosure: { progress, fulfill, reject, configure in
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
        let allTasks: Task<(completedCount: Int, totalCount: Int), [StepCountHistory], NSError> = authenticationTask.then({(succeeded: Bool) -> Task<(completedCount: Int, totalCount: Int), [StepCountHistory], NSError> in
            let calendar = NSCalendar.currentCalendar()
            let now = NSDate()
            let nowComponents = calendar.components(.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit, fromDate: now)
            let startDate = calendar.dateFromComponents(nowComponents)!
            
            var tasks: [HealthStoreStepCountHistoryTask] = []
            for i in 0..<dates {
                let d = i + 1 - dates
                let s = calendar.dateByAddingUnit(.DayCalendarUnit, value: d, toDate: startDate, options: nil)
                let e = calendar.dateByAddingUnit(.DayCalendarUnit, value: d+1, toDate: startDate, options: nil)
                
                let predicate = HKQuery.predicateForSamplesWithStartDate(s, endDate: e, options: .StrictStartDate)
                let sampleType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
                
                let task = HealthStoreStepCountHistoryTask(initClosure: { progress, fulfill, reject, configure in
                    let query = HKStatisticsQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: .CumulativeSum) { query, result, error in
                        if error != nil {
                            reject(error)
                            return
                        }
                        if let history = StepCountHistory(statistics: result) {
                            fulfill(history)
                            return
                        } else {
                            reject(NSError(domain: "", code: 0, userInfo: nil))
                            return
                        }
                    }
                    self.store.executeQuery(query)
                })
                tasks.append(task)
            }
            return Task.some(tasks)
        })
        let resultTask: HealthStoreStepCountHistoryListTask = allTasks.then({(results: [StepCountHistory]) -> HealthStoreStepCountHistoryListTask in
            // TODO: sort results by startDate
            return HealthStoreStepCountHistoryListTask(value: results)
        })
        return resultTask
        /*
        return self.requestAuthorizationTask.then({(succeeded: Bool?, (error: NSError?, isCancelled: Bool?)?) -> Task<(completedCount: Int, totalCount: Int), [StepCountHistory], NSError> in
            let calendar = NSCalendar.currentCalendar()
            let now = NSDate()
            let nowComponents = calendar.components(.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit, fromDate: now)
            let startDate = calendar.dateFromComponents(nowComponents)!
            
            var tasks: [HealthStoreStepCountHistoryTask] = []
            for i in 0..<dates {
                let s = calendar.dateByAddingUnit(.DayCalendarUnit, value: i, toDate: startDate, options: nil)
                let e = calendar.dateByAddingUnit(.DayCalendarUnit, value: i+1, toDate: startDate, options: nil)
                
                let predicate = HKQuery.predicateForSamplesWithStartDate(s, endDate: e, options: .StrictStartDate)
                let sampleType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
                
                let task = HealthStoreStepCountHistoryTask(initClosure: { progress, fulfill, reject, configure in
                    let query = HKStatisticsQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: .CumulativeSum) { query, result, error in
                        if error != nil {
                            reject(error)
                            return
                        }
                        let history = StepCountHistory(statistics: result)
                        fulfill(history)
                        return
                    }
                })
                tasks.append(task)
            }
            return Task.all(tasks)
        }).then({(results: [StepCountHistory]) -> [StepCountHistory] in
            return results
        })
        */
    }
}
