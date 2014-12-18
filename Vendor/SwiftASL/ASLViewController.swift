//
//  ASLViewController.swift
//  YourWalker
//
//  Created by Ono Masashi on 2014/12/18.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

import UIKit

// TODO: should be a class variable
let __ASLTableViewCellTimestampDateFormatter: NSDateFormatter = {
    let dateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
    dateFormatter.dateFormat = "HH:mm:ss"
    return dateFormatter
}()

class __ASLTableViewCell: UITableViewCell {
    
    var timestampLabel: UILabel!
    var messageLabel: UILabel!
    
    var line: ASLLine? {
        didSet {
            if let l = self.line {
                self.timestampLabel.attributedText = __ASLTableViewCell.attributedStringForTimestampLabel(l)
                self.messageLabel.attributedText = __ASLTableViewCell.attributedStringForMessageLabel(l)
            } else {
                self.timestampLabel.attributedText = nil
                self.messageLabel.attributedText = nil
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
        self.contentView.addSubview(self.timestampLabel)
        
        self.messageLabel = UILabel(frame: CGRectZero)
        self.messageLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.messageLabel.font = nil
        self.messageLabel.numberOfLines = 0
        self.messageLabel.textAlignment = .Left
        self.contentView.addSubview(self.messageLabel)
        
        let views = ["timestampLabel": self.timestampLabel, "messageLabel": self.messageLabel]
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(8)-[timestampLabel(60)]-(4)-[messageLabel]-(8)-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(4)-[messageLabel]-(4)-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.timestampLabel, attribute: .Top, relatedBy: .Equal, toItem: self.messageLabel, attribute: .Top, multiplier: 1.0, constant: 0))
    }
    
    class func attributedStringForTimestampLabel(line: ASLLine) -> NSAttributedString {
        let string = __ASLTableViewCellTimestampDateFormatter.stringFromDate(line.timestamp)//    NSDateFormatter.localizedStringFromDate(line.timestamp, dateStyle: .NoStyle, timeStyle: .LongStyle)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Right
        paragraphStyle.lineBreakMode = .ByTruncatingTail
        let attributes: [NSObject:AnyObject] = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: UIFont(name: "Courier", size: 12.0)!,
            NSForegroundColorAttributeName: UIColor(white: 0.30, alpha: 1.0)
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }

    class func attributedStringForMessageLabel(line: ASLLine) -> NSAttributedString {
        let string = line.message
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Left
        paragraphStyle.lineBreakMode = .ByWordWrapping
        let attributes: [NSObject:AnyObject] = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: UIFont(name: "Courier", size: 13.0)!,
            NSForegroundColorAttributeName: UIColor(white: 0.03, alpha: 1.0)
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    class func heightOfLine(line: ASLLine, inSize size: CGSize) -> CGFloat {
        let marginWidth: CGFloat = 8.0 + 60.0 + 4.0 + 8.0
        let marginHeight: CGFloat = 4.0 + 4.0
        let s: CGSize = CGSize(width: size.width - marginWidth, height: size.height)
        let options = NSStringDrawingOptions.UsesLineFragmentOrigin // TODO: should be .UsesFontLeading | .UsesLineFragmentOrigin
        return self.attributedStringForMessageLabel(line).boundingRectWithSize(s, options: options, context: nil).size.height + marginHeight
    }
}

class __ASLTableViewController: UITableViewController {
    
    var lines: [ASLLine] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .None
        self.tableView.registerClass(__ASLTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.title = "Logs"
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
        cell.line = self.lines[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let size = CGSize(width: tableView.bounds.size.width, height: CGFloat.max)
        return __ASLTableViewCell.heightOfLine(self.lines[indexPath.row], inSize: size)
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
