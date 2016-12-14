//
//  ImageLoaderTest.swift
//  Droplet
//
//  Created by MHK on 12/13/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import XCTest
import MapKit
import UIKit
@testable import Droplet

class ImageLoaderTest: XCTestCase {
    
    var imageLoader : ImageLoader?
    var url : String = "https://droplightapi.herokuapp.com/apiv1/local_feed"
    
    override func setUp() {
        super.setUp()
        imageLoader = ImageLoader(url: url)
    }
    
    override func tearDown() {
        super.tearDown()
        imageLoader = nil
    }
    
    func testUrl(){
        XCTAssert(imageLoader?.sourceUrl == url)
    }
    
    func testQueue(){
        XCTAssert(imageLoader?.imageQueue.count == 0)
    }
    
    func testLoadedCards(){
        XCTAssert(imageLoader?.loadedCards.count == 0)
        let coord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let newCard : Card = Card(image: UIImage(named: "test2"), imageUrl: "testUrl", caption: "Caption", location: coord, deviceID: "deviceid", favorite: false)
        imageLoader?.addCard(card: newCard)
        XCTAssert(imageLoader?.loadedCards.count == 1)
        XCTAssert(imageLoader?.seenImages.count == 1)
        XCTAssert((imageLoader?.seenImages.contains("testUrl"))!)
    }
}
