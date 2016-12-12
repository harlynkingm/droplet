//
//  DataController.swift
//  Droplet
//
//  Created by MHK on 12/12/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import Foundation

/**
 Shared object that allows data to be stored within a session
 */
class DataController {
    static let sharedData = DataController()
    
    var userLocation : LocationController? // Keeps track of the user's location
    var browserImages : ImageLoader? // Stores images for the browser view
    var collectionImages : ImageLoader? // Stores images for the collection view
    var effects : EffectsController = EffectsController() // Manages visual effects
}
