//
//  Resources.swift
//  Scoops
//
//  Created by Adrian Polo Alcaide on 02/03/16.
//  Copyright © 2016 Adrian Polo Alcaide. All rights reserved.
//

import Foundation

let azureMobileApplicationURL = "https://scoops-ap.azure-mobile.net/"
let azureMobileApplicationKey = "skMbuqjSrUUqHHMkIXlJzVfwsQVbwW25"

extension MSClient {
    static func currentClient() -> MSClient {
        return MSClient(applicationURLString: azureMobileApplicationURL, applicationKey: azureMobileApplicationKey)
    }
    
    func setCredentialForUser(userId id:String, userToken token:String){
        self.currentUser = MSUser(userId: id)
        self.currentUser.mobileServiceAuthenticationToken = token
    }
}

enum AzureTables:String{
    case News = "News"
}

extension MSClient {
    func getTable(table:AzureTables) -> MSTable{
        return self.tableWithName(table.rawValue)
    }
}