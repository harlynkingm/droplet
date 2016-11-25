//
//  BrowserController.swift
//  Droplight
//
//  Created by MHK on 11/20/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit

class BrowserView: UIView {
    
    var view: UIView!
    
    var delegate : BrowserViewController!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var currentImage : UIImage?
    
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
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
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
            rec.setTranslation(CGPoint.zero, in: rec.view!)
            break
        case .ended:
            let viewX = rec.view!.center.x
            let centerX = rec.view!.bounds.maxX
            let velocityX = rec.velocity(in: rec.view!).x
            
            if viewX > centerX * 0.9 || velocityX > 1000 {
                UIView.animate(withDuration: 0.4, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
                    rec.view!.center = CGPoint(x: rec.view!.center.x + rec.view!.bounds.width/0.9, y: rec.view!.center.y)
                }, completion: { (done : Bool) in
                    // Code on upvote
                    self.delegate.removeCard(card: self)
                })
            } else if viewX < centerX * 0.1 || velocityX < -1000 {
                UIView.animate(withDuration: 0.4, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
                    rec.view!.center = CGPoint(x: rec.view!.center.x - rec.view!.bounds.width/0.9, y: rec.view!.center.y)
                }, completion: { (done : Bool) in
                    //Code on downvote
                    self.delegate.removeCard(card: self)
                })
            } else {
                UIView.animate(withDuration: 0.4, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
                    rec.view!.center = CGPoint(x: rec.view!.bounds.width/2, y: rec.view!.center.y)
                    rec.view!.transform = CGAffineTransform.identity
                })
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
        let minAngle = CGFloat(90)
        let maxAngle = CGFloat(120)
        
        let total = v.bounds.maxX
        let p = (v.center.x - total)/total * 2
        let angle = (minAngle + p*(maxAngle - minAngle) * CGFloat.pi)/180.0
        
        v.transform = CGAffineTransform(rotationAngle: angle)
    }

}
