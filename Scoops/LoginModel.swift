//
//  LoginModel.swift
//  Scoops
//
//  Created by Adrian Polo Alcaide on 02/03/16.
//  Copyright © 2016 Adrian Polo Alcaide. All rights reserved.
//

import Foundation

typealias CompletionBlock = (NSError?) -> Void

let keyUserId = "userId"
let keyTokenId = "tokenId"

func saveUserInDefaults(currentUser: MSUser){
    NSUserDefaults.standardUserDefaults().setObject(currentUser.userId, forKey: keyUserId)
    NSUserDefaults.standardUserDefaults().setObject(currentUser.mobileServiceAuthenticationToken, forKey: keyTokenId)
}

func removeUserInDefaults(){
    NSUserDefaults.standardUserDefaults().removeObjectForKey(keyUserId)
    NSUserDefaults.standardUserDefaults().removeObjectForKey(keyTokenId)
    
}

func loadUserFromDefaults() -> (user: String?, token:String?) {
    let user = NSUserDefaults.standardUserDefaults().objectForKey(keyUserId) as? String
    let token = NSUserDefaults.standardUserDefaults().objectForKey(keyTokenId) as? String
    
    return (user, token)
}

func isUserLogged() -> Bool{
    let userId = NSUserDefaults.standardUserDefaults().objectForKey(keyUserId)
    if let _ = userId {
        return true
    }
    return false
}

func login(loginType:LoginTypes, controller: UIViewController!, animated: Bool, completion:CompletionBlock!){
    let client = MSClient(applicationURLString: azureMobileApplicationURL , applicationKey: azureMobileApplicationKey)
    
    client.loginWithProvider(loginType.rawValue, controller: controller, animated: true) { (user:MSUser?, error:NSError?) -> Void in
        if error != nil {
            completion(error)
        }else{
            // Save user 
            if let user = user{
                saveUserInDefaults(user)
            }
            completion(nil)
        }
    }
}