//
//  MasterViewController.swift
//  Scoops
//
//  Created by Adrian Polo Alcaide on 28/02/16.
//  Copyright © 2016 Adrian Polo Alcaide. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {
    
    // MARK: - Constants
    let showLoginsSegueIdentifier = "showLogins"
    let showNewNewsSegueIdentifier = "addNews"
    
    // MARK: - Variables
    var detailViewController: NewsDetailViewController? = nil
    var objects = [AnyObject]()
    
    var model: NewsViewModelType = PublicNews();
    
    // MARK: - Actions
    
    @IBAction func refreshTable(sender: AnyObject) {
        model.populateNews { (error: NSError?) -> Void in
            if error != nil{
                // SHOW Error
            }else{
                self.tableView.reloadData()
                sender.endRefreshing()
            }
        }
    }
    
    // MARK: - SuperClass Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.populateNews { (error: NSError?) -> Void in
            if error != nil{
                // SHOW Error
            }else{
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        self.title = "News"
        super.viewWillAppear(animated)
        // Works better with RXSwift
        if isUserLogged() {
            // Show Logout
            let showLogOutButton = UIBarButtonItem(image: UIImage(named: "User"), style: UIBarButtonItemStyle.Plain, target: self, action: "openAlertToSelectMeansForModel:")
            showLogOutButton.tintColor = UIColor.whiteColor()
            self.navigationItem.leftBarButtonItem = showLogOutButton
            
            // Show New News
            let addNews = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addNews:")
            addNews.tintColor = UIColor.whiteColor()
            self.navigationItem.rightBarButtonItem = addNews
        }else{
            // Show Login
            let showLoginButton = UIBarButtonItem(image: UIImage(named: "User"), style: UIBarButtonItemStyle.Plain, target: self, action: "showLogins:")
            showLoginButton.tintColor = UIColor.whiteColor()
            self.navigationItem.leftBarButtonItem = showLoginButton
        }
    }
    
    // MARK: - Functions
    func refresh(){
        model.populateNews { (error: NSError?) -> Void in
            if error != nil{
                // SHOW Error
            }else{
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Selectors
    
    func addNews(sender: AnyObject){
        performSegueWithIdentifier(showNewNewsSegueIdentifier, sender: self)
    }
    
    func showLogins(sender: AnyObject){
        performSegueWithIdentifier(showLoginsSegueIdentifier, sender: self)
    }
    
    func logout(sender: AnyObject){
        let showLoginButton = UIBarButtonItem(image: UIImage(named: "User"), style: UIBarButtonItemStyle.Plain, target: self, action: "showLogins:")
        self.navigationItem.leftBarButtonItem = showLoginButton
        removeUserInDefaults()
    }
    
    func insertNewObject(sender: AnyObject) {
        objects.insert(NSDate(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let news = model[section: indexPath.section, indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! NewsDetailViewController
                controller.news = news
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return model.numberOfSections
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model[section]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NewsCell", forIndexPath: indexPath) as! NewsTableViewCell
        let news = model[section: indexPath.section, indexPath.row]
        cell.binding(news.title, imageObservable: news.getImageFromAzure())
        return cell
    }
    
   
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model[section]
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if let _ = model as? UserNews {
            return true
        }
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let news = model[section: indexPath.section, indexPath.row]
            if news.status == StatusNews.Draft{
                let activityViewController = ActivityViewController(message: "Deleting...")
                news.deleteFromAzure({ (error:NSError?) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        activityViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.refresh()
                            })
                        })
                    })
                })
                presentViewController(activityViewController, animated: true, completion: nil)
            }
            
           
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // MARK: - Alert
    
    func openAlertToSelectMeansForModel(sender: AnyObject){
        let alert = UIAlertController(title: "Do you want to...?", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        var showOtherModel = UIAlertAction()
        if let _ = model as? UserNews {
            showOtherModel = UIAlertAction(title: "Public News", style: UIAlertActionStyle.Default) { (action: UIAlertAction) -> Void in
                self.model = PublicNews()
                self.refresh()
            }
        }else{
            showOtherModel = UIAlertAction(title: "User News", style: UIAlertActionStyle.Default) { (action: UIAlertAction) -> Void in
                self.model = UserNews()
                self.refresh()
            }
        }
        
        let logoutAction = UIAlertAction(title: "Logout", style: UIAlertActionStyle.Destructive) { (action: UIAlertAction) -> Void in
            self.logout(self)
            self.model = PublicNews()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action: UIAlertAction) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alert.addAction(showOtherModel)
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
}
