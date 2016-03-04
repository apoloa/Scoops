//
//  NewNews.swift
//  Scoops
//
//  Created by Adrian Polo Alcaide on 03/03/16.
//  Copyright © 2016 Adrian Polo Alcaide. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

class NewNewsViewController: UIViewController {
    
    @IBOutlet weak var newsTitle: UITextField!
    @IBOutlet weak var newsBody: UITextView!
    @IBOutlet weak var newsImage: UIImageView!
    
    private let disposeBag = DisposeBag()
    private var locManager = CLLocationManager()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        locManager.requestWhenInUseAuthorization()
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "save:")
        self.navigationItem.rightBarButtonItem = saveButton
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel:")
        self.navigationItem.leftBarButtonItem = cancelButton
        
        newsTitle.rx_text.asObservable().bindNext { (value) -> Void in
            self.title = value
        }
        .addDisposableTo(disposeBag)
    
    }
    
    func save(sender: AnyObject){
        
        let currentLocation = LocationManager.sharedInstance.currentLocation
        
        var latitude : Double = 0
        var longitude : Double = 0
        
        if let location = currentLocation {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
        }
        
        let model = News(title: newsTitle.text!, text: newsBody.text!, latitude: latitude, longitude: longitude, status: StatusNews.Draft)
        model.uploadToAzure()
    }
    
    func cancel(sender: AnyObject){
        
    }
    
    
}
