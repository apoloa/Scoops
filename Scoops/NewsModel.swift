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

struct News {
    let title : String
    let text : String
    let latitude : Double
    let longitude : Double
    let status : StatusNews
    var image : UIImage
    let nameImage: String
    var score: Int = 0
    var total_likes: Int = 0
    var downloadedImage = false
    
    init(title: String, text: String, latitude: Double, longitude: Double, image: UIImage, status: StatusNews){
        self.title = title
        self.text = text
        self.latitude = latitude
        self.longitude = longitude
        self.image = image
        self.nameImage = NSUUID().UUIDString
        self.status = status
    }
    
    init(title: String, text: String, latitude: Double, longitude: Double, image: UIImage, imageName:String, status: StatusNews){
        self.title = title
        self.text = text
        self.latitude = latitude
        self.longitude = longitude
        self.image = image
        self.nameImage = imageName
        self.status = status
    }
    
    init(dictionary : NSDictionary){
        self.title = dictionary["title"] as! String
        self.text = dictionary["text"] as! String
        self.latitude = dictionary["latitude"] as! Double
        self.longitude = dictionary["longitude"] as! Double
        self.status = StatusNews(rawValue: dictionary["status"] as! Int)!
        self.nameImage = dictionary["photo"] as! String
        self.score = dictionary["score"] as! Int
        self.total_likes = dictionary["total_likes"] as! Int
        self.image = UIImage(named: "photo_placeholder.png")!
    }
    
    mutating func getImageFromAzure() -> Observable<UIImage>{
        return Observable.create({ (observer) in
            if self.downloadedImage {
                observer.onNext(self.image)
            }else{
                let account = AZSCloudStorageAccount.currentCloudStorageAccount()
                let client = account.getBlobClient()
                let container = client.containerReferenceFromName(azureContainerForImages)
                let blob = container.blockBlobReferenceFromName(self.nameImage)
                blob.downloadToDataWithCompletionHandler({ (error: NSError?, data: NSData?) -> Void in
                    if error != nil {
                        print("Error getting blob \(error)")
                        observer.onError(error!)
                    }else{
                        let image = UIImage(data: data!)!
                        self.image = image
                        self.downloadedImage = true
                        observer.onNext(image)
                    }
                })
            }
            return AnonymousDisposable {
                
            }
        })
    }
    
    
}

extension News{
    func uploadToAzure(){
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
                                            }else{
                                                print("Uploaded files")
                                            }
                                        })
                                    }
                                    
                                }
                            })
                        }
                })
        }
    }
}