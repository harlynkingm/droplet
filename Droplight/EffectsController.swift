//
//  EffectsController.swift
//  Droplight
//
//  Created by MHK on 11/12/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit

class EffectsController {
    
    func blurView(view: UIView, radius: CGFloat){
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
        blur.frame = view.bounds
        blur.isUserInteractionEnabled = false
        blur.layer.cornerRadius = radius
        blur.clipsToBounds = true
        blur.alpha = 0.8
        view.insertSubview(blur, at: 0)
    }
    
}
