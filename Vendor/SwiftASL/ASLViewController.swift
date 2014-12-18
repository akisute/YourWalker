//
//  ASLViewController.swift
//  YourWalker
//
//  Created by Ono Masashi on 2014/12/18.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

import UIKit

class __ASLTableViewCell: UITableViewCell {
    
    var timestampLabel: UILabel!
    var messageLabel: UILabel!
    
    var line: ASLLine? {
        didSet {
            if let l = self.line {
                self.timestampLabel.attributedText = __ASLTableViewCell.attributedStringForTimestampLabel(l)
                self.messageLabel.text = l.message
            } else {
                self.timestampLabel.attributedText = nil
                self.messageLabel.text = nil
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInitialize()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.commonInitialize()
    }
    
    func commonInitialize() {
        self.selectionStyle = .None
        
        self.timestampLabel = UILabel(frame: CGRectZero)
        self.timestampLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.timestampLabel.font = nil
        self.timestampLabel.numberOfLines = 1
        self.timestampLabel.textAlignment = .Right
        self.timestampLabel.backgroundColor = UIColor.redColor()
        self.contentView.addSubview(self.timestampLabel)
        
        self.messageLabel = UILabel(frame: CGRectZero)
        self.messageLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.messageLabel.font = nil
        self.messageLabel.numberOfLines = 0
        self.messageLabel.textAlignment = .Left
        self.messageLabel.backgroundColor = UIColor.orangeColor()
        self.contentView.addSubview(self.messageLabel)
        
        let views = ["timestampLabel": self.timestampLabel, "messageLabel": self.messageLabel]
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(8)-[timestampLabel(80)]-(12)-[messageLabel]-(8)-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(4)-[messageLabel]-(4)-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.timestampLabel, attribute: .Top, relatedBy: .Equal, toItem: self.messageLabel, attribute: .Top, multiplier: 1.0, constant: 0))
    }
    
    class func attributedStringForTimestampLabel(line: ASLLine) -> NSAttributedString {
        let string = NSDateFormatter.localizedStringFromDate(line.timestamp, dateStyle: .NoStyle, timeStyle: .LongStyle)
        let attributes: [NSObject:AnyObject] = [
            NSFontAttributeName: UIFont(name: "Courier", size: 12.0)!,
            NSForegroundColorAttributeName: UIColor(white: 0.25, alpha: 1.0)
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
//
//    class func attributedStringForMessageLabel(line: ASLLine) -> NSAttributedString {
//        
//    }
    
    class func heightWithLine(line: ASLLine) -> CGFloat {
        return 128.0
    }
}

class __ASLTableViewController: UITableViewController {
    
    var lines: [ASLLine] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .None
        self.tableView.registerClass(__ASLTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "onDoneButton:")
        
        self.lines += ASL().readlines()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lines.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as __ASLTableViewCell
        //cell.textLabel!.text = self.lines[indexPath.row].message
        cell.line = self.lines[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return __ASLTableViewCell.heightWithLine(self.lines[indexPath.row])
    }
    
    func onDoneButton(sender: AnyObject) {
        self.navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

/// A convenient view controller to display ASL lines in an app.
/// 
/// Just simply instantiate ASLViewController then present it by presentViewController:animated:completion:
///
public class ASLViewController: UINavigationController {
    
    public override init() {
        super.init()
        self.commonInitialize()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInitialize()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.commonInitialize()
    }
    
    public override init(rootViewController: UIViewController) {
        NSException(name: NSInternalInconsistencyException, reason: "init(rootViewController:) is forbidden for this class. Use other initializers instead.", userInfo: nil).raise()
        super.init(rootViewController: rootViewController)
    }
    
    public override init(navigationBarClass: AnyClass!, toolbarClass: AnyClass!) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        self.commonInitialize()
    }
    
    private func commonInitialize() {
        let viewControllers = [__ASLTableViewController(style: .Plain)]
        self.viewControllers = viewControllers
    }
    
}
