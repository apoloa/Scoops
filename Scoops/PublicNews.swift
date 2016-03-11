//
//  File.swift
//  Scoops
//
//  Created by Adrian Polo Alcaide on 07/03/16.
//  Copyright © 2016 Adrian Polo Alcaide. All rights reserved.
//

import Foundation

class PublicNews : NewsViewModelType {
    
    var news = [News]()
    
    init(){
        
    }
    
    func populateNews(completion: CompletionBlock){
        let client = MSClient.currentClient()
        let table = client.getTable(AzureTables.News)
        let predicate = NSPredicate(format: "status == %d", StatusNews.Published.rawValue)
        let query = table.queryWithPredicate(predicate)
        
        query.readWithCompletion { (result:MSQueryResult?, error:NSError?) -> Void in
            if error != nil {
                print("Error getting results \(error)")
                completion(error)
            }else{
                print("Results: \(result?.items)")
                if let items = result?.items as? [NSDictionary]{
                    self.news = items.map({ (dictionary:NSDictionary) -> News in
                        return News(dictionary: dictionary)
                    })
                    completion(nil)
                }
            }
        }
    }
    
    var numberOfSections: Int { get{
            return 1
        }
    }
        
    subscript(section: Int) -> Int { get{
            return news.count
        }
    }
    
    subscript(section: Int) -> String { get {
            return "Last News"
        }
    }
    
    subscript(section sect: Int , row: Int) -> News { get {
            return self.news[row]
        }
    }
}