//
//  BrowserController.swift
//  Droplight
//
//  Created by MHK on 11/20/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit
import MapKit

class BrowserView: UIView {
    
    var view: UIView!
    
    var delegate : BrowserViewController!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var caption: UILabel!
    
    var currentImage : UIImage!
    var currentLocation: CLLocationCoordinate2D!
    
    var e: EffectsController = EffectsController()
    
    func updateImage() {
        if let image : UIImage = currentImage {
            imageView.image = image
        }
    }
    
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
        e.addShadow(view: imageView, opacity: 0.5, offset: CGSize.zero, radius: 20.0, color: nil)
        imageView.addSubview(caption)
    }
    
    init(frame: CGRect, image: UIImage, captionText: String, location: CLLocationCoordinate2D){
        super.init(frame: frame)
        xibSetup()
        currentLocation = location
        currentImage = image
        updateImage()
        if (captionText.characters.count > 0){
            caption.text = captionText
        } else {
            caption.isHidden = true
        }
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        xibSetup()
//    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        xibSetup()
    }
    
    @IBAction func pan(rec:UIPanGestureRecognizer) {
        
        let translation:CGPoint = rec.translation(in: self)
        
        switch rec.state {
        case .began:
            break
        case .changed:
            translateX(t: translation, v: rec.view!)
            rotate(v: rec.view!)
            delegate.thumbAnimation(current: rec.view!.center.x - self.view.center.x)
            rec.setTranslation(CGPoint.zero, in: rec.view!)
            break
        case .ended:
            let viewX = rec.view!.center.x
            let centerX = rec.view!.bounds.maxX
            let velocityX = rec.velocity(in: rec.view!).x
            
            if viewX > centerX * 0.9 || velocityX > 1000 {
                upvote()
            } else if viewX < centerX * 0.1 || velocityX < -1000 {
                downvote()
            } else {
                UIView.animate(withDuration: 0.4, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
                    rec.view!.center = CGPoint(x: rec.view!.bounds.width/2, y: rec.view!.center.y)
                    rec.view!.transform = CGAffineTransform.identity
                })
                self.delegate.resetThumbs()
            }
            break
        default:
            break
        }
    }
    
    func translateX(t : CGPoint, v: UIView){
        v.center = CGPoint(x:v.center.x + t.x, y:v.center.y)
    }
    
    func rotate(v: UIView){
        let minAngle = CGFloat(-15)
        let maxAngle = CGFloat(15)
        
        let p = v.center.x/view.bounds.maxX
        let angle = ((minAngle + p*(maxAngle - minAngle)) * CGFloat.pi)/180.0
        
        v.transform = CGAffineTransform(rotationAngle: angle)
    }
    
    func upvote(){
        UIView.animate(withDuration: 0.4, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
            self.imageView.center = CGPoint(x: self.imageView.center.x + self.imageView.bounds.width/0.9, y: self.imageView.center.y)
            self.imageView.transform = CGAffineTransform(rotationAngle: (15 * CGFloat.pi)/180.0)
        }, completion: { (done : Bool) in
            // Code on upvote
            self.delegate.removeCard(card: self)
            self.delegate.resetThumbs()
        })
    }
    
    func downvote(){
        UIView.animate(withDuration: 0.4, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
            self.imageView.center = CGPoint(x: self.imageView.center.x - self.imageView.bounds.width/0.9, y: self.imageView.center.y)
            self.imageView.transform = CGAffineTransform(rotationAngle: (-15 * CGFloat.pi)/180.0)
        }, completion: { (done : Bool) in
            //Code on downvote
            self.delegate.removeCard(card: self)
            self.delegate.resetThumbs()
        })
    }

}
