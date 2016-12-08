//
//  CardModel.swift
//  Droplet
//
//  Created by MHK on 12/7/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit
import MapKit

struct Card {
    var image : UIImage?
    let imageUrl : String
    let caption : String
    let location : CLLocationCoordinate2D
    let deviceID : String
}
