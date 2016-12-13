//
//  LocationController.swift
//  Droplight
//
//  Created by MHK on 11/17/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import MapKit

/**
 Allows view controllers to listen to location received events
 */
protocol  LocationControllerDelegate : class {
    func didGetLocation(sender: LocationController)
}

/**
 Given a url, gets a list of images and creates Cards based on the data retrieved.
 */
class LocationController: NSObject, CLLocationManagerDelegate{
    
    // Defines location and placemark for keeping track of location name
    var manager = CLLocationManager()
    var location: CLLocation!
    var placemark: CLPlacemark?
    
    weak var delegate: LocationControllerDelegate?
    
    override init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    /**
     CLLocationManagerDelegate function for when locations are received
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation: CLLocation = locations[locations.count - 1]
        location = latestLocation
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
            if error == nil && (placemarks?.count)! > 0 {
                self.placemark = (placemarks?[0])! as CLPlacemark
                self.delegate?.didGetLocation(sender: self)
            }
        })
    }
    
    /**
     Required function for the CLLocationManagerDelegate, no implementation necessary
     */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { }
}
