//
//  HistoryDisplayViewCell.swift
//  YourWalker
//
//  Created by 小野 将司 on 2014/11/25.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

import UIKit

class HistoryDisplayViewCell: UITableViewCell {
    
    @IBOutlet var stepCountLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    var stepCountHistory: StepCountHistory? {
        didSet {
            self.updateOutlets()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        self.updateOutlets()
    }

    private func updateOutlets() {
        if let value = self.stepCountHistory {
            self.stepCountLabel.text = FormatterManager.sharedInstance.numberFormatter_Decimal.stringFromNumber(value.stepCount)
            self.dateLabel.text = FormatterManager.sharedInstance.dateFormatter_MMDD.stringFromDate(value.displayDate)
        } else {
            self.stepCountLabel.text = nil
            self.dateLabel.text = nil
        }
    }
}
