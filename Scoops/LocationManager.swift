//
//  LocationManager.swift
//  Scoops
//
//  Created by Adrian Polo Alcaide on 04/03/16.
//  Copyright © 2016 Adrian Polo Alcaide. All rights reserved.
//

import UIKit
import MapKit

class LocationManager : NSObject {
    static let sharedInstance = LocationManager()
    
    private var locManager = CLLocationManager()

    var currentLocation: CLLocation? {
        get{
            if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways ||
                CLLocationManager.authorizationStatus() ==  CLAuthorizationStatus.AuthorizedWhenInUse) {
                    return locManager.location
            }
            return nil
        }
    }
    
    override init(){
        super.init()
        if !CLLocationManager.locationServicesEnabled() {
            
        }
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startMonitoringSignificantLocationChanges()
        locManager.delegate = self
        
        
    }
    
}

extension LocationManager: CLLocationManagerDelegate{
    
}