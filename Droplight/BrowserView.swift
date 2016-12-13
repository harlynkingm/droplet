//
//  BrowserController.swift
//  Droplight
//
//  Created by MHK on 11/20/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit
import MapKit

/**
 View that displays a card in the Browser View Controller
 */
class BrowserView: UIView {
    
    //MARK: - Initializers
    
    var view: UIView!
    
    var delegate : BrowserViewController!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var caption: UILabel!
    
    var currentCard : Card!
    var currentImage : UIImage!
    var currentLocation: CLLocationCoordinate2D!
    
    var effects: EffectsController = DataController.sharedData.effects
    
    // MARK: - Setup Functions
    
    func loadViewFromNib(name: String) -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: name, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func xibSetup() {
        view = loadViewFromNib(name: "BrowserView")
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
        effects.addShadow(view: imageView, opacity: 0.5, offset: CGSize.zero, radius: 20.0, color: nil)
        imageView.addSubview(caption)
    }
    
    init(frame: CGRect, card: Card){
        super.init(frame: frame)
        xibSetup()
        currentCard = card
        currentLocation = card.location
        currentImage = card.image!
        updateImage()
        if (card.caption.characters.count > 0){
            caption.text = card.caption
        } else {
            caption.isHidden = true
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        xibSetup()
    }
    
    // MARK: - User Actions
    
    /**
     Gesture recognizer built into BrowserView that handles touch/swipe events
     */
    @IBAction func pan(rec:UIPanGestureRecognizer) {
        let translation:CGPoint = rec.translation(in: self)
        
        switch rec.state {
        case .began:
            break
        case .changed:
            translateX(t: translation, v: imageView)
            rotate(v: imageView)
            delegate.thumbAnimation(current: imageView.center.x - self.view.center.x)
            rec.setTranslation(CGPoint.zero, in: imageView)
            break
        case .ended:
            let viewX = imageView.center.x
            let centerX = imageView.bounds.maxX
            let velocityX = rec.velocity(in: imageView).x
            
            if viewX > centerX * 0.9 || velocityX > 1000 {
                upvote()
            } else if viewX < centerX * 0.1 || velocityX < -1000 {
                downvote()
            } else {
                UIView.animate(withDuration: 0.4, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
                    self.imageView.center = CGPoint(x: self.imageView.bounds.width/2, y: self.imageView.center.y)
                    self.imageView.transform = CGAffineTransform.identity
                })
                self.delegate.resetThumbs()
            }
            break
        default:
            break
        }
    }
    
    /**
     Sends a BrowserView away to the right, will eventually make a server call
     */
    func upvote(){
        UIView.animate(withDuration: 0.4, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
            self.imageView.center = CGPoint(x: self.imageView.center.x + self.imageView.bounds.width/0.9, y: self.imageView.center.y)
            self.imageView.transform = CGAffineTransform(rotationAngle: (15 * CGFloat.pi)/180.0)
        }, completion: { (done : Bool) in
            // Code on upvote
            self.delegate.removeCard(view: self)
            self.delegate.resetThumbs()
        })
    }
    
    /**
     Sends a BrowserView away to the left, will eventually make a server call
     */
    func downvote(){
        UIView.animate(withDuration: 0.4, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
            self.imageView.center = CGPoint(x: self.imageView.center.x - self.imageView.bounds.width/0.9, y: self.imageView.center.y)
            self.imageView.transform = CGAffineTransform(rotationAngle: (-15 * CGFloat.pi)/180.0)
        }, completion: { (done : Bool) in
            // Code on downvote
            self.delegate.removeCard(view: self)
            self.delegate.resetThumbs()
        })
    }
    
    // MARK: - View Updating Functions
    
    /**
     Translates a view by a transform property
     
     - parameter t: The transformation to make on the view
     - parameter v: The view to transform
     */
    func translateX(t : CGPoint, v: UIView){
        v.center = CGPoint(x:v.center.x + t.x, y:v.center.y)
    }
    
    /**
     Rotates a given view based on its distance from the center of the screen based on a min and max angle
     
     - parameter v: The view to rotate
     */
    func rotate(v: UIView){
        let minAngle = CGFloat(-15)
        let maxAngle = CGFloat(15)
        
        let p = v.center.x/view.bounds.maxX
        let angle = ((minAngle + p*(maxAngle - minAngle)) * CGFloat.pi)/180.0
        
        v.transform = CGAffineTransform(rotationAngle: angle)
    }
    
    func updateImage() {
        if let image : UIImage = currentImage {
            imageView.image = image
        }
    }

}
