//
//  BrowserViewController.swift
//  Droplight
//
//  Created by MHK on 11/20/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit

class BrowserViewController: UIViewController {
    
    @IBOutlet weak var placeholder : UIView!
    
    var tempPictures: [String] = ["test1", "test2", "test3", "test2", "test3", "test1", "test2", "test3", "test1", "test2"]
    
    var cards: [BrowserView] = [BrowserView]()

    override func viewDidLoad() {
        super.viewDidLoad()
        renderCards()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func renderCards() {
        for picture in tempPictures {
            let image = UIImage(named: picture)
            let browserView = BrowserView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
            browserView.delegate = self
            browserView.currentImage = image
            browserView.updateImage()
            self.placeholder.addSubview(browserView)
            cards.append(browserView)
        }
    }
    
    func removeCard(card: BrowserView){
        card.removeFromSuperview()
    }


}
