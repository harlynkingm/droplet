//
//  CollectionViewController.swift
//  Droplet
//
//  Created by MHK on 12/8/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit
import MapKit

/**
 Allows the user to see photos they've taken and their favorites
 */
class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate, ImageLoaderDelegate {
    
    // MARK: - Initializers
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var gradient: UIView!
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var displayImage: UIImageView!
    @IBOutlet weak var previewImage: UIView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    
    var effects : EffectsController = DataController.sharedData.effects
    var userLocation : LocationController? = DataController.sharedData.userLocation
    var browserImages : ImageLoader? = DataController.sharedData.browserImages
    var collectionImages : ImageLoader? = DataController.sharedData.collectionImages
    
    var cards : [Card] = []
    var displayCards : [Card] = []
    var currentCard : Int = 0
    
    var favoritesMode : Bool = false
    var mapOn : Bool = false

    // MARK: - Setup Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tempCards = collectionImages?.loadedCards {
            cards.append(contentsOf: tempCards)
            refreshDisplay(showFavorites: favoritesMode)
        }
        if (displayCards.count > 0){
            noImageLabel.isHidden = true
        }
        collectionImages?.delegate = self
        collectionImages?.refresh()
        collection.delegate = self
        collection.dataSource = self
        collection.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "ImageCell")
        mapView.delegate = self
        effects.addDefaultShadow(view: cameraButton)
        effects.addDefaultShadow(view: userButton)
        effects.addDefaultShadow(view: favoriteButton)
        effects.addDefaultShadow(view: locationButton)
        effects.addDefaultShadow(view: shareButton)
        effects.addDefaultShadow(view: closeButton)
        effects.addShadow(view: header, opacity: 0.5, offset: CGSize.zero, radius: 20.0, color: nil)
        effects.addGradient(view: gradient, start: UIColor.clear, end: UIColor.white, opacity: 0.5)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: - Collection View Functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayCards.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collection.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath as IndexPath)
        let newView : UIImageView = UIImageView(image: displayCards[indexPath.row].image)
        newView.contentMode = UIViewContentMode.scaleAspectFill
        newView.clipsToBounds = true
        cell.backgroundView = newView
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentCard = indexPath.row
        let cardToShow : Card = displayCards[currentCard]
        previewImage.isUserInteractionEnabled = true
        displayImage.image = cardToShow.image!
        UIView.animate(withDuration: 0.3, animations: {
            self.previewImage.alpha = 1.0
        })
    }
    
    // MARK: - User Actions
    
    @IBAction func userPressed(){
        refreshDisplay(showFavorites: false)
        UIView.transition(with: userButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.userButton.setImage(UIImage(named: "user_on"), for: UIControlState.normal)
        }, completion: nil)
        UIView.transition(with: favoriteButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.favoriteButton.setImage(UIImage(named: "favorite_off"), for: UIControlState.normal)
        }, completion: nil)
        UIView.transition(with: headerLabel, duration: 0.3, options: .transitionFlipFromRight, animations: {
            self.headerLabel.text = "Your Collection"
        }, completion: nil)
    }
    
    @IBAction func favoritePressed(){
        refreshDisplay(showFavorites: true)
        UIView.transition(with: favoriteButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.favoriteButton.setImage(UIImage(named: "favorite_on"), for: UIControlState.normal)
        }, completion: nil)
        UIView.transition(with: userButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.userButton.setImage(UIImage(named: "user_off"), for: UIControlState.normal)
        }, completion: nil)
        UIView.transition(with: headerLabel, duration: 0.3, options: .transitionFlipFromLeft, animations: {
            self.headerLabel.text = "Your Favorites"
        }, completion: nil)
    }
    
    @IBAction private func dragPicture(_ rec: UIPanGestureRecognizer) {
        let translation = rec.translation(in: rec.view)
        
        switch rec.state {
        case .began:
            break
        case .changed:
            if ((rec.view?.transform.ty)! >= CGFloat(0)){
                rec.view?.transform = (rec.view?.transform.translatedBy(x: 0, y: translation.y * 1.1))!
                rec.setTranslation(CGPoint.zero, in: rec.view)
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    rec.view?.transform = CGAffineTransform.identity
                })
            }
            break
        case .ended:
            if (rec.velocity(in: rec.view).y > 1000){
                closeImage()
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    rec.view?.transform = CGAffineTransform.identity
                })
            }
            break
        default:
            break
        }
    }
    
    @IBAction func sharePressed(){
        loading.startAnimating()
        if (cards.count > 0) {
            var activityItem: [AnyObject] = [displayCards[currentCard].image as AnyObject]
            let message : String = "Check out what I found on Droplet!"
            activityItem.append(message as AnyObject)
            let vc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
            vc.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
            self.present(vc, animated: true, completion: {
                self.loading.stopAnimating()
            })
        }
    }
    
    @IBAction func closePressed(){
        closeImage()
    }
    
    @IBAction func locationPressed(){
        mapOn = !mapOn
        let items : [UIView] = [self.locationButton, self.cameraButton, self.shareButton, self.mapView]
        if (mapOn){
            locationButton.setImage(UIImage(named: "location_on"), for: .normal)
            setRegion(location: displayCards[currentCard].location)
            animateMany(items: items, distance: CGPoint(x: 0, y: -1 * self.mapView.frame.height), length: 0.3)
        } else {
            locationButton.setImage(UIImage(named: "location_off"), for: .normal)
            animateMany(items: items, distance: CGPoint(x: 0, y: self.mapView.frame.height), length: 0.3)
        }
    }
    
    // MARK: - Display Updating Functions
    
    func refreshDisplay(showFavorites: Bool){
        self.favoritesMode = showFavorites
        if (showFavorites){
            displayCards = cards.filter { $0.favorite }
        } else {
            displayCards = cards.filter { !$0.favorite }
        }
        collection.reloadData()
        if (displayCards.count > 0){
            noImageLabel.isHidden = true
        } else {
            noImageLabel.isHidden = false
        }
    }
    
    func didLoadCard(sender: ImageLoader, newCard: Card) {
        cards.append(newCard)
        refreshDisplay(showFavorites: favoritesMode)
    }
    
    func closeImage(){
        if (mapOn){
            locationPressed()
        }
        UIView.animate(withDuration: 0.5, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
            self.previewImage.transform = self.previewImage.transform.translatedBy(x: 0, y: self.previewImage.bounds.height * 2)
        }, completion: { (done : Bool) in
            self.previewImage.isUserInteractionEnabled = false
            self.previewImage.alpha = 0
            self.previewImage.transform = CGAffineTransform.identity
        })
    }
    
    func animateMany(items: [UIView], distance: CGPoint, length: TimeInterval){
        UIView.animate(withDuration: length, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
            for item in items{
                item.transform = item.transform.translatedBy(x: distance.x, y: distance.y)
            }
        }, completion: nil)
    }
    
    // MARK: - Map Updating Functions
    
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

}
