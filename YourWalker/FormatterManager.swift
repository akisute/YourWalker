//
//  FormatterManager.swift
//  YourWalker
//
//  Created by 小野 将司 on 2014/11/25.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

import UIKit

class FormatterManager {
    
    class var sharedInstance : FormatterManager {
        struct Static {
            static let instance : FormatterManager = FormatterManager()
        }
        return Static.instance
    }
    
    lazy var dateFormatter_MMDD: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "MM/dd"
        return dateFormatter
    }()
    
    lazy var numberFormatter_Decimal: NSNumberFormatter = {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.locale = NSLocale(localeIdentifier: "en_US")
        numberFormatter.numberStyle = .DecimalStyle
        return numberFormatter
    }()
}
