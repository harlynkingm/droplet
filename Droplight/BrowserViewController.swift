//
//  BrowserViewController.swift
//  Droplight
//
//  Created by MHK on 11/20/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit
import MapKit

class BrowserViewController: UIViewController, ImageLoaderDelegate, MKMapViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
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
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var gesture : UIPanGestureRecognizer!
    
    @IBOutlet weak var thumbsDownConst: NSLayoutConstraint!
    @IBOutlet weak var thumbsUpConst: NSLayoutConstraint!
    
    var mapOn : Bool = false
    var favoriteOn: Bool = false
    var passGesture: Bool = false
    
    var e: EffectsController = EffectsController()
    var l: LocationController?
    var i: ImageLoader?
    
    var tempPictures: [UIImage] = [UIImage(named: "test1")!, UIImage(named: "test2")!, UIImage(named: "test3")!, UIImage(named: "test2")!]
    
    var cards: [BrowserView] = [BrowserView]()
    var currentCard : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        scrollView.delegate = self
        gesture.delegate = self
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.phase == UITouchPhase.began && bottomButtons.frame.contains(touch.preciseLocation(in: bottomButtons)) && cards.count > 0){
            passGesture = false
        } else if (touch.phase == UITouchPhase.began){
            passGesture = true
        }
        return passGesture
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        mapButtonFade(scrollView: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) { mapButtonFade(scrollView: scrollView) }
    }
    
    func mapButtonFade(scrollView: UIScrollView){
        let height = scrollView.frame.size.height
        let contentSize = scrollView.contentSize.height
        let offset = scrollView.contentOffset.y
        let p = offset/(contentSize - height)
        UIView.transition(with: mapButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            if (p >= 0.5){
                self.mapOn = true
                self.mapButton.setImage(UIImage(named: "location_on"), for: UIControlState.normal)
                if (self.cards.count > 0) { self.setRegion(location: self.cards[self.currentCard].currentLocation) }
            } else {
                self.mapOn = false
                self.mapButton.setImage(UIImage(named: "location_off"), for: UIControlState.normal)
            }
        }, completion: nil)
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
            setMap(enabled: !mapOn)
        }
    }
    
    func setMap(enabled: Bool){
        mapOn = enabled
        if enabled {
            if (cards.count > 0) { setRegion(location: cards[currentCard].currentLocation) }
            let bottom : CGPoint = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
            scrollView.setContentOffset(bottom, animated: true)
            UIView.transition(with: mapButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.mapButton.setImage(UIImage(named: "location_on"), for: UIControlState.normal)
            }, completion: nil)
        } else {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            UIView.transition(with: mapButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.mapButton.setImage(UIImage(named: "location_off"), for: UIControlState.normal)
            }, completion: nil)
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
    
    @IBAction func pan(rec:UIPanGestureRecognizer) {
        switch rec.state {
        case .began:
            break
        case .changed:
            if (passGesture && cards.count > 0){
                cards[currentCard].pan(rec: rec)
            }
            break
        case .ended:
            if (passGesture && cards.count > 0){
                cards[currentCard].pan(rec: rec)
            }
            passGesture = false
            break
        default:
            break
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
        let buttons : [UIButton] = [self.mapButton, self.favoriteButton, self.shareButton]
        setViewsOpacity(views: buttons, opacity: 1)
        self.thumbsUpConst.constant = -80
        self.thumbsDownConst.constant = -80
        UIView.transition(with: favoriteButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.favoriteButton.setImage(UIImage(named: "favorite_off"), for: UIControlState.normal)
        }, completion: nil)
        if (cards.count == 0){
            self.thumbsUpConst.constant = -140
            self.thumbsDownConst.constant = -140
            setViewsOpacity(views: buttons, opacity: 0.5)
            setMap(enabled: false)
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
        if (cards.count == 1) { setRegion(location: cards[currentCard].currentLocation) }
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
