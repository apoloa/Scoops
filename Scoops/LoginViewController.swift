//
//  LoginViewController.swift
//  Scoops
//
//  Created by Adrian Polo Alcaide on 01/03/16.
//  Copyright © 2016 Adrian Polo Alcaide. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let client = MSClient(
    applicationURLString: "https://scoops-ap.azure-mobile.net/", applicationKey: "skMbuqjSrUUqHHMkIXlJzVfwsQVbwW25")

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
    }
    
    @IBAction func twitterLogin(sender: AnyObject) {
        
    }

    @IBAction func facebookLogin(sender: AnyObject) {
        login(LoginTypes.Facebook, controller: self, animated: true) { (error:NSError?) -> Void in
            if error != nil{
                print("Error login facebook: \(error)")
            }
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}
