//
//  BrowserViewController.swift
//  Droplight
//
//  Created by MHK on 11/20/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

/**
 Allows the user to browse through local photos taken in their area
 */
class BrowserViewController: UIViewController, ImageLoaderDelegate, MKMapViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Initializers
    
    @IBOutlet weak var placeholder : UIView!
    @IBOutlet weak var backButton : UIButton!
    @IBOutlet weak var mapButton : UIButton!
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var thumbsUp : UIButton!
    @IBOutlet weak var thumbsDown : UIButton!
    @IBOutlet weak var favoriteButton : UIButton!
    @IBOutlet weak var bottomButtons: UIStackView!
    @IBOutlet weak var loadingView : UIView!
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var gesture : UIPanGestureRecognizer!
    
    @IBOutlet weak var thumbsDownConst: NSLayoutConstraint!
    @IBOutlet weak var thumbsUpConst: NSLayoutConstraint!
    
    var mapOn : Bool = false
    var favoriteOn: Bool = false
    var passGesture: Bool = false
    
    var effects : EffectsController = DataController.sharedData.effects
    var userLocation : LocationController? = DataController.sharedData.userLocation
    var browserImages : ImageLoader? = DataController.sharedData.browserImages
    var collectionImages : ImageLoader? = DataController.sharedData.collectionImages
    
    var cards: [BrowserView] = [BrowserView]()
    var currentCard : Int = 0
    
    // MARK: - Setup Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        scrollView.delegate = self
        gesture.delegate = self
        if (browserImages != nil){
            browserImages?.delegate = self
            renderCards(cards: (browserImages?.loadedCards)!)
            browserImages?.refresh()
        }
        resetThumbs()
        effects.addDefaultShadow(view: backButton)
        effects.addDefaultShadow(view: mapButton)
        effects.addDefaultShadow(view: favoriteButton)
        effects.addDefaultShadow(view: thumbsUp)
        effects.addDefaultShadow(view: thumbsDown)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        browserImages?.delegate = nil
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: - User Actions
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.phase == UITouchPhase.began && bottomButtons.frame.contains(touch.preciseLocation(in: bottomButtons)) && cards.count > 0){
            passGesture = false
        } else if (touch.phase == UITouchPhase.began){
            passGesture = true
        }
        return passGesture
    }
    
    @IBAction func toggleMap(){
        if (cards.count > 0){
            setMap(enabled: !mapOn)
        }
    }
    
    @IBAction func toggleFavorite(){
        if (cards.count > 0){
            favoriteOn = !favoriteOn
            addFavorite(card: cards[currentCard].currentCard, isFavorite: favoriteOn)
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
    
    @IBAction func upvote(){
        if (cards.count > 0) { self.cards[currentCard].upvote() }
    }
    
    @IBAction func downvote(){
        if (cards.count > 0) { self.cards[currentCard].downvote() }
    }
    
    // MARK: - Scroll View Handlers
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        mapButtonFade(scrollView: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) { mapButtonFade(scrollView: scrollView) }
    }
    
    // MARK: - View Updating Functions
    
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
        let buttons : [UIButton] = [self.mapButton, self.favoriteButton]
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
    
    // MARK: - Card Rendering Functions
    
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
    
    func didLoadCard(sender: ImageLoader, newCard: Card) {
        addCard(card: newCard)
        if (cards.count == 1) { setRegion(location: cards[currentCard].currentLocation) }
        resetThumbs()
    }
    
    // MARK: - Map Updating Functions
    
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
    
    func setRegion(location : CLLocationCoordinate2D){
        for annotation in mapView.annotations {
            self.mapView.removeAnnotation(annotation)
        }
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
    
    // MARK: - Favoriting Functions
    
    func addFavorite(card: Card, isFavorite: Bool){
        favoriteButton.isUserInteractionEnabled = false
        let deviceID = (UIDevice.current.identifierForVendor?.uuidString)! as String!
        let latitude : String = "\(card.location.latitude)"
        let longitude : String = "\(card.location.longitude)"
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(card.imageUrl.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName :"url")
                multipartFormData.append(latitude.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName :"latitude")
                multipartFormData.append(longitude.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName :"longitude")
                multipartFormData.append("\(deviceID)".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName :"device")
                multipartFormData.append(card.caption.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName :"caption")
                multipartFormData.append("\(isFavorite)".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName :"favorite")
        },
            to: "https://droplightapi.herokuapp.com/apiv1/favorites",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        print(NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue) as! String)
                        self.cards[self.currentCard].currentCard.favorite = isFavorite
                        if (isFavorite){
                            self.favoriteButton.setImage(UIImage(named: "favorite_on"), for: UIControlState.normal)
                        } else {
                            self.favoriteButton.setImage(UIImage(named: "favorite_off"), for: UIControlState.normal)
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
                self.favoriteButton.isUserInteractionEnabled = true
        })
    }

}
