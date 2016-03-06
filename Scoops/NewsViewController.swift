//
//  MasterViewController.swift
//  Scoops
//
//  Created by Adrian Polo Alcaide on 28/02/16.
//  Copyright © 2016 Adrian Polo Alcaide. All rights reserved.
//

import UIKit

class NewsViewController: UITableViewController {

    let showLoginsSegueIdentifier = "showLogins"
    let showNewNewsSegueIdentifier = "addNews"
    
    var detailViewController: DetailViewController? = nil
    var objects = [AnyObject]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = MSClient.currentClient()
        
       
        
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        // Works better with RXSwift
        if isUserLogged() {
            // Show Logout
            let showLogOutButton = UIBarButtonItem(title: "LogOut", style: UIBarButtonItemStyle.Plain, target: self, action: "logout:")
            self.navigationItem.leftBarButtonItem = showLogOutButton
            
            // Show New News
            let addNews = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addNews:")
            self.navigationItem.rightBarButtonItem = addNews
        }else{
            // Show Login
            let showLoginButton = UIBarButtonItem(title: "LogIn", style: UIBarButtonItemStyle.Plain, target: self, action: "showLogins:")
            self.navigationItem.leftBarButtonItem = showLoginButton
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addNews(sender: AnyObject){
        performSegueWithIdentifier(showNewNewsSegueIdentifier, sender: self)
    }
    
    func showLogins(sender: AnyObject){
        performSegueWithIdentifier(showLoginsSegueIdentifier, sender: self)
    }
    
    func logout(sender: AnyObject){
        let showLoginButton = UIBarButtonItem(title: "LogIn", style: UIBarButtonItemStyle.Plain, target: self, action: "showLogins:")
        self.navigationItem.rightBarButtonItem = showLoginButton
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
                let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row] as! NSDate
        cell.textLabel!.text = object.description
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

