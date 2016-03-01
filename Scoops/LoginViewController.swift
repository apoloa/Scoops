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

    @IBAction func twitterLogin(sender: AnyObject) {
        
    }

    @IBAction func facebookLogin(sender: AnyObject) {
        client.loginWithProvider(LoginTypes.Facebook.rawValue, controller: self, animated: true) { (user:MSUser?, error:NSError?) -> Void in
            if error != nil {
                print("Error Logging user: \(error)")
            } else {
                // Save credentials
                print("User logged \(user?.userId) with \(user?.mobileServiceAuthenticationToken)")
                
                
            }
        }
    }
}
