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
    @IBOutlet weak var thumbsUp : UIButton!
    @IBOutlet weak var thumbsDown : UIButton!
    
    @IBOutlet weak var thumbsDownConst: NSLayoutConstraint!
    @IBOutlet weak var thumbsUpConst: NSLayoutConstraint!
    
    var mapOn : Bool = false
    
    var e: EffectsController = EffectsController()
    
    var tempPictures: [UIImage] = [UIImage(named: "test1")!, UIImage(named: "test2")!, UIImage(named: "test3")!, UIImage(named: "test2")!]
    
    var cards: [BrowserView] = [BrowserView]()
    var currentCard : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        renderCards(pictures: tempPictures)
        e.addShadow(view: backButton, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
        e.addShadow(view: mapButton, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
        e.addShadow(view: thumbsUp, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
        e.addShadow(view: thumbsDown, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func renderCards(pictures : [UIImage]) {
        for image in pictures {
            addCard(image: image)
        }
    }
    
    func addCard(image: UIImage){
        let browserView = BrowserView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        browserView.delegate = self
        browserView.currentImage = image
        browserView.updateImage()
        self.placeholder.insertSubview(browserView, at: 0)
        cards.append(browserView)
    }
    
    func removeCard(card: BrowserView){
        card.removeFromSuperview()
        currentCard += 1
    }
    
    @IBAction func toggleMap(){
        mapOn = !mapOn
        if mapOn {
            mapButton.setImage(UIImage(named: "location_on"), for: UIControlState.normal)
            UIView.animate(withDuration: 0.2, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
                self.mapButton.transform = self.mapButton.transform.translatedBy(x: 0, y: -1 * self.mapView.frame.height)
                self.mapView.transform = self.mapView.transform.translatedBy(x: 0, y: -1 * self.mapView.frame.height)
            })
        } else {
            mapButton.setImage(UIImage(named: "location_off"), for: UIControlState.normal)
            UIView.animate(withDuration: 0.2, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
                self.mapButton.transform = self.mapButton.transform.translatedBy(x: 0, y: self.mapView.frame.height)
                self.mapView.transform = self.mapView.transform.translatedBy(x: 0, y: self.mapView.frame.height)
            })
        }
    }
    
    func thumbAnimation(current: CGFloat){
        if (current >= 0){
            self.thumbsUpConst.constant = -50
            self.thumbsDownConst.constant = -80
            UIView.animate(withDuration: 0.2, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
                self.view.layoutIfNeeded()
            })
        } else if (current < 0){
            self.thumbsUpConst.constant = -80
            self.thumbsDownConst.constant = -50
            UIView.animate(withDuration: 0.2, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func resetThumbs(){
        self.thumbsUpConst.constant = -80
        self.thumbsDownConst.constant = -80
        if (currentCard >= cards.count){
            self.thumbsUpConst.constant = -140
            self.thumbsDownConst.constant = -140
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func upvote(){
        self.cards[currentCard].upvote()
    }

    @IBAction func downvote(){
        self.cards[currentCard].downvote()
    }

}
