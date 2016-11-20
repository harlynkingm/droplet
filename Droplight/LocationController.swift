//
//  LocationController.swift
//  Droplight
//
//  Created by MHK on 11/17/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import MapKit

protocol  LocationControllerDelegate : class {
    func didGetLocation(sender: LocationController)
}

class LocationController: NSObject, CLLocationManagerDelegate{
    
    var manager = CLLocationManager()
    var location: CLLocation!
    var placemark: CLPlacemark?
    
    weak var delegate: LocationControllerDelegate?
    
    override init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // returns when location received
        let latestLocation: CLLocation = locations[locations.count - 1]
        location = latestLocation
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
            if error == nil && (placemarks?.count)! > 0 {
                self.placemark = (placemarks?[0])! as CLPlacemark
                self.delegate?.didGetLocation(sender: self)
            }
        })
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
}
