import Foundation

class UserNews : NewsViewModelType {
    
    var publishedNews = [News]()
    var draftNews = [News]()
    var publishNews = [News]()
    
    init(){
        
    }
    
    func populateNews(completion: CompletionBlock){
        let client = MSClient.currentClient()
        let table = client.getTable(AzureTables.News)
        let usrLogin = loadUserFromDefaults()
        client.setCredentialForUser(userId: usrLogin.user!, userToken: usrLogin.token!)
        client.getUserId { (userId:String?, error:NSError?) -> Void in
            if error != nil {
                print("Error getting user id \(error)")
            }else{
                let predicate = NSPredicate(format: "author == %@", userId!)
                print("Predicate \(predicate)")
                let query = table.queryWithPredicate(predicate)
                query.readWithCompletion { (result:MSQueryResult?, error:NSError?) -> Void in
                    if error != nil {
                        print("Error getting results \(error)")
                        completion(error)
                    }else{
                        print("Results: \(result?.items)")
                        if let items = result?.items as? [NSDictionary]{
                            let news = items.map({ (dictionary:NSDictionary) -> News in
                                return News(dictionary: dictionary)
                            })
                            
                            for n in news{
                                switch n.status{
                                case .Draft:
                                    self.draftNews.append(n)
                                    break
                                case .Publish:
                                    self.publishNews.append(n)
                                    break
                                case .Published:
                                    self.publishedNews.append(n)
                                }
                            }
                            
                            completion(nil)
                        }
                    }
                }
            }
            
        }
        
    }
    
    var numberOfSections: Int {
        get{
            return 3
        }
    }
    
    subscript(section: Int) -> Int {
        get{
            switch section{
            case 0:
                return draftNews.count
            case 1:
                return publishNews.count
            case 2:
                return publishedNews.count
            default:
                return 0
            }
        }
    }
    
    subscript(section: Int) -> String {
        get {
            switch section{
            case 0:
                return "Draft"
            case 1:
                return "Publish"
            case 2:
                return "Published"
            default:
                return "Unknown"
            }
        }
        
    }
    
    subscript(section sect: Int , row: Int) -> News {
        get {
            switch sect{
            case 0:
                return draftNews[row]
            case 1:
                return publishNews[row]
            case 2:
                return publishedNews[row]
            default:
                return draftNews[row]
            }
        }
    }
}