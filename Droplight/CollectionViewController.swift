//
//  CollectionViewController.swift
//  Droplet
//
//  Created by MHK on 12/8/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ImageLoaderDelegate {
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var gradient: UIView!
    @IBOutlet weak var noImageLabel: UILabel!
    
    var e : EffectsController = EffectsController()
    var l : LocationController?
    var i : ImageLoader?
    var c : ImageLoader?
    
    var cards : [Card] = []
    var displayCards : [Card] = []
    
    var favoritesMode : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if let tempCards = c?.loadedCards {
            cards.append(contentsOf: tempCards)
            refreshDisplay(showFavorites: favoritesMode)
        }
        if (displayCards.count > 0){
            noImageLabel.isHidden = true
        }
        c?.delegate = self
        c?.refresh()
        collection.delegate = self
        collection.dataSource = self
        collection.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "ImageCell")
        e.addShadow(view: cameraButton, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
        e.addShadow(view: userButton, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
        e.addShadow(view: favoriteButton, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
        e.addShadow(view: header, opacity: 0.5, offset: CGSize.zero, radius: 20.0, color: nil)
        e.addGradient(view: gradient, start: UIColor.clear, end: UIColor.white, opacity: 0.5)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier!){
        case "OpenCamera":
            if let destination = segue.destination as? CameraViewController {
                destination.l = self.l
                destination.i = self.i
                destination.c = self.c
            }
            break
        default:
            break
        }
    }
    
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
        print(indexPath)
    }
    
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

}
