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

let azureStorageConnectionString = "DefaultEndpointsProtocol=https;AccountName=scoopsapstore;AccountKey=2EMjjaf/9ZkI8H1is4IR65CRctkrmM3KpE15zReF0pffJ3wWsFCJRKCHfgQJYlY+R0pdPQ0lCzWxNL1/AVL6dw=="

let azureBlobURL = "https://scoopsapstore.blob.core.windows.net"

let azureCustomAPIGetSASUrlForBlob = "getsasurl"

let azureContainerForImages = "images"

let azureCustomAPIGetSASUrlForBlobParamBlobName = "blobName"

let azureCustomAPIGetSASUrlForBlobParamContainerName = "ContainerName"

enum HTTPMethods : String{
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

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

extension MSClient {
    func getSASBlobUrl(blobName: String, completionBlock:(NSError?, NSURL?)-> Void ){
        self.invokeAPI(azureCustomAPIGetSASUrlForBlob,
            body: nil,
            HTTPMethod: HTTPMethods.GET.rawValue,
            parameters: [azureCustomAPIGetSASUrlForBlobParamBlobName: blobName,
                azureCustomAPIGetSASUrlForBlobParamContainerName: azureContainerForImages],
            headers: nil) { (result: AnyObject?, response: NSHTTPURLResponse?, error: NSError?) -> Void in
                if error != nil {
                    completionBlock(error, nil)
                }else{
                    let sasURL = result!["sasUrl"] as? String
                    
                    let urlString = azureBlobURL + sasURL!
                    
                    if let url = NSURL(string: urlString){
                        completionBlock(nil,url)
                    }
                }
        }
    }
}

extension AZSCloudStorageAccount{
    static func currentCloudStorageAccount() -> AZSCloudStorageAccount{
        return AZSCloudStorageAccount(fromConnectionString: azureStorageConnectionString)
    }
}
