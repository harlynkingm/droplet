//
//  BrowserViewController.swift
//  Droplight
//
//  Created by MHK on 11/20/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit
import MapKit

class BrowserViewController: UIViewController, ImageLoaderDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var placeholder : UIView!
    @IBOutlet weak var backButton : UIButton!
    @IBOutlet weak var mapButton : UIButton!
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var thumbsUp : UIButton!
    @IBOutlet weak var thumbsDown : UIButton!
    @IBOutlet weak var favoriteButton : UIButton!
    @IBOutlet weak var shareButton : UIButton!
    @IBOutlet weak var bottomButtons: UIStackView!
    @IBOutlet weak var loadingView : UIView!
    
    @IBOutlet weak var thumbsDownConst: NSLayoutConstraint!
    @IBOutlet weak var thumbsUpConst: NSLayoutConstraint!
    
    var mapOn : Bool = false
    var favoriteOn: Bool = false
    
    var e: EffectsController = EffectsController()
    var l: LocationController?
    var i: ImageLoader?
    
    var tempPictures: [UIImage] = [UIImage(named: "test1")!, UIImage(named: "test2")!, UIImage(named: "test3")!, UIImage(named: "test2")!]
    
    var cards: [BrowserView] = [BrowserView]()
    var currentCard : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        if (i != nil){
            i?.delegate = self
            renderCards(cards: (i?.loadedCards)!)
            i?.refresh()
        }
        //renderCards(pictures: tempPictures)
        resetThumbs()
        e.addShadow(view: backButton, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
        e.addShadow(view: mapButton, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
        e.addShadow(view: thumbsUp, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
        e.addShadow(view: thumbsDown, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
        e.addShadow(view: favoriteButton, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
        e.addShadow(view: shareButton, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        i?.delegate = nil
        if let destination = segue.destination as? CameraViewController {
            destination.l = self.l
            destination.i = self.i
        }
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func renderCards(cards : [Card]) {
        for card in cards {
            addCard(card: card)
        }
    }
    
    func addCard(card: Card){
        let frame : CGRect = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        let browserView = BrowserView(frame: frame, card: card)
        browserView.delegate = self
        self.placeholder.insertSubview(browserView, at: 0)
        cards.append(browserView)
        loadingView.isHidden = true
    }
    
    func removeCard(card: BrowserView){
        card.removeFromSuperview()
        cards.remove(at: 0)
        if (cards.count > 0) { setRegion(location: cards[currentCard].currentLocation) }
    }
    
    @IBAction func toggleMap(){
        if (cards.count > 0){
            mapOn = !mapOn
            if mapOn {
                if (cards.count > 0) { setRegion(location: cards[currentCard].currentLocation) }
                mapButton.setImage(UIImage(named: "location_on"), for: UIControlState.normal)
                UIView.animate(withDuration: 0.2, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
                    self.bottomButtons.transform = self.bottomButtons.transform.translatedBy(x: 0, y: -1 * self.mapView.frame.height)
                    self.mapView.transform = self.mapView.transform.translatedBy(x: 0, y: -1 * self.mapView.frame.height)
                })
            } else {
                mapButton.setImage(UIImage(named: "location_off"), for: UIControlState.normal)
                UIView.animate(withDuration: 0.2, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
                    self.bottomButtons.transform = self.bottomButtons.transform.translatedBy(x: 0, y: self.mapView.frame.height)
                    self.mapView.transform = self.mapView.transform.translatedBy(x: 0, y: self.mapView.frame.height)
                })
            }
        }
    }
    
    @IBAction func toggleFavorite(){
        if (cards.count > 0){
            favoriteOn = !favoriteOn
            if (favoriteOn){
                favoriteButton.setImage(UIImage(named: "favorite_on"), for: UIControlState.normal)
            } else {
                favoriteButton.setImage(UIImage(named: "favorite_off"), for: UIControlState.normal)
            }
        }
    }
    
    @IBAction func toggleShare(){
        if (cards.count > 0) {
            //loading.startAnimating()
            var activityItem: [AnyObject] = [cards[currentCard].currentImage as AnyObject]
            let message : String = "Check out what I found on Droplet!"
            activityItem.append(message as AnyObject)
            let vc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
            vc.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
            self.present(vc, animated: true, completion: {
                //self.loading.stopAnimating()
            })
        }
    }
    
    func limitCenter(view : UIView, translation : CGPoint, minX : CGFloat, minY : CGFloat, maxX : CGFloat, maxY : CGFloat){
        let currentCenter = view.center
        var newCenter = CGPoint(x: currentCenter.x + translation.x, y: currentCenter.y + translation.y)
        newCenter.x = min(maxX, max(minX, newCenter.x))
        newCenter.y = min(maxY, max(minY, newCenter.y))
        view.center = newCenter
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
        let buttons : [UIButton] = [self.favoriteButton, self.mapButton, self.shareButton]
        setViewsOpacity(views: buttons, opacity: 1)
        self.thumbsUpConst.constant = -80
        self.thumbsDownConst.constant = -80
        if (cards.count == 0){
            self.thumbsUpConst.constant = -140
            self.thumbsDownConst.constant = -140
            setViewsOpacity(views: buttons, opacity: 0.5)
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func setViewsOpacity(views: [UIView], opacity: CGFloat){
        for view in views{
            UIView.animate(withDuration: 0.2, animations: {
                view.alpha = opacity
            })
        }
    }
    
    @IBAction func upvote(){
        if (cards.count > 0) { self.cards[currentCard].upvote() }
    }

    @IBAction func downvote(){
        if (cards.count > 0) { self.cards[currentCard].downvote() }
    }
    
    func didLoadCard(sender: ImageLoader, newCard: Card) {
        addCard(card: newCard)
        resetThumbs()
    }
    
    func setRegion(location : CLLocationCoordinate2D){
        let drop = MKPointAnnotation()
        drop.coordinate = location
        drop.title = "Image Location"
        mapView.addAnnotation(drop)
        var region : MKCoordinateRegion = MKCoordinateRegion()
        region.center = location
        region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) { return nil }
        let reuseID = "droplet"
        var v = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if (v != nil){
            v?.annotation = annotation
        } else {
            v = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            v?.image = UIImage(named: "drop_pin")
            v?.canShowCallout = true
        }
        return v
    }

}
