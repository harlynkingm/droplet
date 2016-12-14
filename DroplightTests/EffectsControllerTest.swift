//
//  EffectsControllerTest.swift
//  Droplet
//
//  Created by MHK on 12/14/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import XCTest
import UIKit
@testable import Droplet

class EffectsControllerTest: XCTestCase {
    
    var view : UIView?
    var effects : EffectsController = EffectsController()
    
    override func setUp() {
        super.setUp()
        view = UIView()
    }
    
    override func tearDown() {
        super.tearDown()
        view = nil
    }
    
    func testShadow(){
        effects.addShadow(view: view!, opacity: 1.0, offset: CGSize.zero, radius: 0, color: UIColor(white:0.75, alpha:1.0))
        XCTAssert(view?.layer.shadowOpacity == 1.0)
        XCTAssert(view?.layer.shadowOffset == CGSize.zero)
    }
    
    func testDefaultShadow(){
        effects.addDefaultShadow(view: view!)
        XCTAssert(view?.layer.shadowOffset == CGSize(width: 0, height: 3))
        XCTAssert(view!.layer.shadowColor == UIColor(white:0.75, alpha:1.0).cgColor)
    }
    
    func testGradient(){
        effects.addGradient(view: view!, start: UIColor(white: 1.0, alpha: 1.0), end: UIColor(white: 0, alpha: 0), opacity: 0.7)
        let sublayer : CAGradientLayer = (view!.layer.sublayers![0] as? CAGradientLayer)!
        XCTAssert(sublayer.colors?[0] as! CGColor == UIColor(white: 1.0, alpha: 1.0).cgColor)
        XCTAssert(sublayer.opacity == 0.7)
    }
    
}
