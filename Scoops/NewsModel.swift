//
//  NewsModel.swift
//  Scoops
//
//  Created by Adrian Polo Alcaide on 03/03/16.
//  Copyright © 2016 Adrian Polo Alcaide. All rights reserved.
//

import Foundation
import RxSwift

enum StatusNews: Int{
    case Draft = 0
    case Publish = 1
    case Published = 2
}

class News {
    var id : String?
    let title : String
    var text : String
    let latitude : Double
    let longitude : Double
    var status : StatusNews
    var image : UIImage
    let nameImage: String
    var score: Double = 0
    var total_likes: Double = 0
    var downloadedImage : Bool
    var author: String?
    
    init(title: String, text: String, latitude: Double, longitude: Double, image: UIImage, status: StatusNews){
        self.title = title
        self.text = text
        self.latitude = latitude
        self.longitude = longitude
        self.image = image
        self.nameImage = NSUUID().UUIDString
        self.status = status
        self.downloadedImage = false
    }
    
    init(title: String, text: String, latitude: Double, longitude: Double, image: UIImage, imageName:String, status: StatusNews){
        self.title = title
        self.text = text
        self.latitude = latitude
        self.longitude = longitude
        self.image = image
        self.nameImage = imageName
        self.status = status
        self.downloadedImage = false
    }
    
    init(dictionary : NSDictionary){
        self.id = dictionary["id"] as? String
        self.title = dictionary["title"] as! String
        self.text = dictionary["text"] as! String
        self.latitude = dictionary["latitude"] as! Double
        self.longitude = dictionary["longitude"] as! Double
        self.status = StatusNews(rawValue: dictionary["status"] as! Int)!
        self.nameImage = dictionary["photo"] as! String
        self.score = dictionary["score"] as! Double
        self.total_likes = dictionary["total_likes"] as! Double
        self.image = UIImage(named: "photo_image_empty.png")!
        self.author = dictionary["authorname"] as? String
        self.downloadedImage = false
    }
    
    func getImageFromAzure() -> Observable<UIImage>{
        return Observable.create({ (observer) in
            if self.downloadedImage == true {
                print("Sending Image Saved")
                observer.onNext(self.image)
            }else{
                observer.onNext(self.image)
                let account = AZSCloudStorageAccount.currentCloudStorageAccount()
                let client = account.getBlobClient()
                let container = client.containerReferenceFromName(azureContainerForImages)
                let blob = container.blockBlobReferenceFromName(self.nameImage)
                blob.downloadToDataWithCompletionHandler({ (error: NSError?, data: NSData?) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if error != nil {
                            print("Error getting blob \(error)")
                            observer.onError(error!)
                        }else{
                            let image = UIImage(data: data!)! 
                            self.image = image
                            print("Image Downloaded")
                            self.downloadedImage = true
                            observer.onNext(image)
                        }
                    })
                    
                })
            }
            return AnonymousDisposable {
                self.downloadedImage = false
            }
        })
    }
    
    
}

extension News{
    func uploadToAzure(completionBlock: CompletionBlock){
        let usrLogin = loadUserFromDefaults()
        if let user = usrLogin.user,
            token = usrLogin.token{
                print("Location \(latitude) -- \(longitude)")
                let client = MSClient.currentClient()
                client.setCredentialForUser(userId: user, userToken: token)
                let tableNews = client.getTable(AzureTables.News)
                tableNews.insert([
                    "title": title,
                    "text":text,
                    "latitude":latitude,
                    "longitude":longitude,
                    "photo": nameImage,
                    "status":status.rawValue
                    ], completion: { (inserted, error:NSError?) -> Void in
                        if error != nil {
                            print("Tememos un error -> : \(error)")
                            completionBlock(error)
                        } else {
                            print("Insertado")
                            client.getSASBlobUrl(self.nameImage, completionBlock: { (error:NSError?, url:NSURL?) -> Void in
                                if error != nil{
                                    print("Error GetSASBlobl \(error)")
                                }else{
                                    let container = AZSCloudBlobContainer(url: url!)
                                    let blobLocal = container.blockBlobReferenceFromName(self.nameImage)
                                    if let pngData = UIImageJPEGRepresentation(self.image, 0.5){
                                        blobLocal.uploadFromData(pngData, completionHandler: { (error: NSError?) -> Void in
                                            if error != nil {
                                                print("Error uploading file \(error)")
                                                completionBlock(nil)
                                            }else{
                                                print("Uploaded files")
                                                completionBlock(nil)
                                            }
                                        })
                                    }
                                    
                                }
                            })
                        }
                })
        }
    }
    
    func modifyInAzure(completionBlock: CompletionBlock)
    {
        let usrLogin = loadUserFromDefaults()
        if let user = usrLogin.user,
            token = usrLogin.token{
                let client = MSClient.currentClient()
                client.setCredentialForUser(userId: user, userToken: token)
                let tableNews = client.getTable(.News)
                tableNews.update(["id": self.id!,"text" : text, "status":status.rawValue], completion: { (dictionary:[NSObject : AnyObject]!, error:NSError!) -> Void in
                    if error != nil {
                        completionBlock(error)
                    }else{
                        if let pngData = UIImageJPEGRepresentation(self.image, 0.5){
                            let account = AZSCloudStorageAccount.currentCloudStorageAccount()
                            let client = account.getBlobClient()
                            let container = client.containerReferenceFromName(azureContainerForImages)
                            let blob = container.blockBlobReferenceFromName(self.nameImage)
                            blob.uploadFromData(pngData, completionHandler: { (error: NSError?) -> Void in
                                if error != nil {
                                    print("Error uploading file \(error)")
                                    completionBlock(nil)
                                }else{
                                    print("Uploaded files")
                                    completionBlock(nil)
                                }
                            })
                            
                        }
                    }
                    
                })
        }
    }
    
    func deleteFromAzure(completionBlock:CompletionBlock){
        let usrLogin = loadUserFromDefaults()
        if let user = usrLogin.user,
            token = usrLogin.token{
                let client = MSClient.currentClient()
                client.setCredentialForUser(userId: user, userToken: token)
                let tableNews = client.getTable(.News)
                tableNews.delete(["id": self.id!], completion: { (object:AnyObject?, error:NSError!) -> Void in
                    if error != nil {
                        completionBlock(error)
                    }else{
                        completionBlock(nil)
                    }
                })
        }
    }
}

extension News{
    func setPuntuation(puntuation: Double, completionBlock:CompletionBlock){
        let client = MSClient.currentClient()
        client.setPuntuationNews(self.id!, puntuation: puntuation, completionBlock: completionBlock)
    }
}