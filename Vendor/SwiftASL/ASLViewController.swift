//
//  ASLViewController.swift
//  YourWalker
//
//  Created by Ono Masashi on 2014/12/18.
//  Copyright (c) 2014年 akisute. All rights reserved.
//

import UIKit

private class __ASLTableViewCell: UITableViewCell {
    
    private required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInitialize()
    }
    
    private override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.commonInitialize()
    }
    
    private func commonInitialize() {
        self.selectionStyle = .None
    }
}

class __ASLTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .None
        self.tableView.registerClass(__ASLTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "onDoneButton:")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as __ASLTableViewCell
        cell.textLabel!.text = "abesi"
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
    
    func onDoneButton(sender: AnyObject) {
        self.navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

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
