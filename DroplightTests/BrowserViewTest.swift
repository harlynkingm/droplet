//
//  BrowserViewTest.swift
//  Droplet
//
//  Created by MHK on 12/14/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit
import MapKit
import XCTest
@testable import Droplet

class BrowserViewTest: XCTestCase {
    
    var browserView: BrowserView?
    
    var testCard : Card?

    override func setUp() {
        super.setUp()
        let coord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        testCard = Card(image: UIImage(named: "test1"), imageUrl: "testUrl", caption: "Test Caption", location: coord, deviceID: "testid", favorite: false)
        browserView = BrowserView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 100)), card: testCard!)
    }
    
    override func tearDown() {
        super.tearDown()
        browserView = nil
    }
    
    func testCardProperties() {
        XCTAssert(browserView?.currentImage == testCard?.image)
        XCTAssert(browserView?.caption.text == testCard?.caption)
        XCTAssert(browserView?.currentLocation.latitude == testCard?.location.latitude)
    }
    
    func testTranslateX(){
        let originalPoint = browserView?.imageView.center
        let transform = CGPoint(x: 10, y: 10)
        browserView?.translateX(t: transform, v: (browserView?.imageView)!)
        XCTAssert(browserView?.imageView.center == CGPoint(x: originalPoint!.x + transform.x, y: originalPoint!.y))
    }
    
    func testRotate(){
        browserView?.rotate(v: (browserView?.imageView)!)
        let p = (browserView?.imageView.center.x)!/(browserView?.bounds.maxX)!
        let angle = ((-15 + p*30) * CGFloat.pi)/180.0
        XCTAssert(browserView?.imageView.transform == CGAffineTransform(rotationAngle: angle))
    }
}
