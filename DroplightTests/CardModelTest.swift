//
//  CardModelTest.swift
//  Droplet
//
//  Created by MHK on 12/13/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import XCTest
import MapKit
import UIKit
@testable import Droplet

class CardModelTest: XCTestCase {
    
    var testCard: Card?
    
    override func setUp() {
        super.setUp()
        let coord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        testCard = Card(image: nil, imageUrl: "testUrl", caption: "Test Caption", location: coord, deviceID: "testid", favorite: false)
    }
    
    override func tearDown() {
        super.tearDown()
        testCard = nil
    }
    
    func testCreateCard() {
        XCTAssert(testCard?.image == nil)
        XCTAssert(testCard?.imageUrl == "testUrl")
        XCTAssert(testCard?.caption == "Test Caption")
        XCTAssert(testCard?.location.latitude == 0)
        XCTAssert(testCard?.deviceID == "testid")
        XCTAssert(testCard?.favorite == false)
        testCard?.image = UIImage(named: "test1")
        XCTAssert(testCard?.image == UIImage(named: "test1"))
    }
}
