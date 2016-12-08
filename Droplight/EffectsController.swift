//
//  EffectsController.swift
//  Droplight
//
//  Created by MHK on 11/12/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit

// Handles image effects like background blur
class EffectsController {
    
    func blurView(view: UIView, radius: CGFloat){
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
        blur.frame = view.bounds
        blur.isUserInteractionEnabled = false
        blur.layer.cornerRadius = radius
        blur.clipsToBounds = true
        blur.alpha = 0.8
        if view is UILabel {
            view.superview?.addSubview(blur)
            blur.addSubview(view)
        } else {
            view.insertSubview(blur, at: 0)
        }
    }
    
    func addShadow(view: UIView, opacity: Float, offset: CGSize, radius: CGFloat, color: UIColor?){
        view.layer.shadowOpacity = opacity
        view.layer.shadowOffset = offset
        view.layer.shadowRadius = radius
        if let uiColor = color {
            view.layer.shadowColor = uiColor.cgColor
        }
    }
    
    func adjustShadow(view: UIView, newOffset: CGSize){
        view.layer.shadowOffset = newOffset
    }
    
    func addGradient(view: UIView, start: UIColor, end: UIColor, opacity: Float){
        let top = start.cgColor
        let bottom = end.cgColor
        let gl : CAGradientLayer = CAGradientLayer()
        gl.colors = [top, bottom]
        gl.locations = [0.0, 1.0]
        gl.frame = view.bounds
        gl.opacity = opacity
        view.layer.insertSublayer(gl, at: 0)
    }
    
}
