//
//  EffectsController.swift
//  Droplight
//
//  Created by MHK on 11/12/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit

/**
 Handles view effects like shadow and gradient
 */
class EffectsController {
    
    /**
     Adds a shadow to the given view
     
     - parameter view: The view to add the shadow to
     - parameter opacity: The opacity of the shadow
     - parameter offset: The X and Y based offset of the shadow
     - parameter radius: The radius of the shadow expansion
     - parameter color: The color of the shadow
     */
    func addShadow(view: UIView, opacity: Float, offset: CGSize, radius: CGFloat, color: UIColor?){
        view.layer.shadowOpacity = opacity
        view.layer.shadowOffset = offset
        view.layer.shadowRadius = radius
        if let uiColor = color {
            view.layer.shadowColor = uiColor.cgColor
        }
    }
    
    /**
     Adds a shadow with default properties to the given view
     
     - parameter view: The view to add the shadow to
     */
    func addDefaultShadow(view: UIView){
        addShadow(view: view, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
    }
    
    /**
     Adjusts the shadow on a view by the given offset
     
     - parameter view: The view to adjust
     - parameter newOffset: The offset to add to the view shadow
     */
    func adjustShadow(view: UIView, newOffset: CGSize){
        view.layer.shadowOffset = newOffset
    }
    
    /**
     Adds a gradient to the given view
     
     - parameter view: The view to add the gradient effect to
     - parameter start: The starting color of the gradient
     - parameter end: The ending color of the gradient
     - parameter opacity: The opacity of the gradient
     */
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
