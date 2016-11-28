//
//  BrowserViewController.swift
//  Droplight
//
//  Created by MHK on 11/20/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit
import MapKit

class BrowserViewController: UIViewController {
    
    @IBOutlet weak var placeholder : UIView!
    @IBOutlet weak var backButton : UIButton!
    @IBOutlet weak var mapButton : UIButton!
    @IBOutlet weak var mapView : MKMapView!
    
    var mapOn : Bool = false
    
    var e: EffectsController = EffectsController()
    
    var tempPictures: [String] = ["test1", "test2", "test3", "test2", "test3", "test1", "test2", "test3", "test1", "test2"]
    
    var cards: [BrowserView] = [BrowserView]()

    override func viewDidLoad() {
        super.viewDidLoad()
        renderCards()
        e.addShadow(view: backButton, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
        e.addShadow(view: mapButton, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func renderCards() {
        for picture in tempPictures {
            let image = UIImage(named: picture)
            let browserView = BrowserView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
            browserView.delegate = self
            browserView.currentImage = image
            browserView.updateImage()
            self.placeholder.addSubview(browserView)
            cards.append(browserView)
        }
    }
    
    func removeCard(card: BrowserView){
        card.removeFromSuperview()
    }
    
    @IBAction func toggleMap(){
        mapOn = !mapOn
        if mapOn {
            UIView.animate(withDuration: 0.2, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
                self.mapButton.transform = self.mapView.transform.translatedBy(x: 0, y: -1 * self.mapView.frame.height)
                self.mapView.transform = self.mapView.transform.translatedBy(x: 0, y: -1 * self.mapView.frame.height)
            })
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
                self.mapButton.transform = self.mapView.transform.translatedBy(x: 0, y: self.mapView.frame.height)
                self.mapView.transform = self.mapView.transform.translatedBy(x: 0, y: self.mapView.frame.height)
            })
        }
    }


}
