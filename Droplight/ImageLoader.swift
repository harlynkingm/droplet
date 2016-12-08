//
//  ImageLoader.swift
//  Droplet
//
//  Created by MHK on 12/5/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import Alamofire
import UIKit
import MapKit
import Foundation

protocol ImageLoaderDelegate : class {
    func didLoadCard(sender: ImageLoader, newCard: Card)
}

class ImageLoader : NSObject {
    
    weak var delegate : ImageLoaderDelegate?
    
    var sourceUrl : String
    
    var imageQueue : [Card]
    var loadedCards : [Card]
    var seenImages : Set<String>
    
    init(url: String) {
        sourceUrl = url
        loadedCards = []
        imageQueue = []
        seenImages = Set<String>()
        super.init()
        loadImageList(url: url)
    }
    
    func loadImageList(url: String){
        Alamofire.request(url).responseJSON{ response in
            if (response.data!.count > 2){
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String:Any]
                    let images = parsedData["images"] as! [NSDictionary]
                    for card in images {
                        let caption = card["caption"] as! String
                        let device = card["device"] as! String
                        let imageUrl = card["filename"] as! String
                        let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(Float(card["latitude"] as! String)!), longitude: CLLocationDegrees(Float(card["longitude"] as! String)!))
                        let favorite : Bool = card["favorite"] as! String == "true" ? true: false
                        if (!self.seenImages.contains(imageUrl)){
                            let newCard = Card(image: nil, imageUrl: imageUrl, caption: caption, location: location, deviceID: device, favorite: favorite)
                            self.imageQueue.append(newCard)
                            self.seenImages.insert(imageUrl)
                        }
                    }
                    self.processQueue()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func processQueue(){
        if (imageQueue.count > 0){
            var card : Card = imageQueue.popLast()!
            let url : String = card.imageUrl
            Alamofire.request(url).response { response in
                let newImage : UIImage! = UIImage(data: response.data!, scale: 1)
                card.image = newImage
                self.addCard(card: card)
                self.processQueue()
            }
        }
    }
    
    func addCard(card : Card){
        if (!self.seenImages.contains(card.imageUrl)){
            self.seenImages.insert(card.imageUrl)
        }
        loadedCards.append(card)
        if let d = delegate {
            d.didLoadCard(sender: self, newCard: card)
        }
    }
    
    func refresh(){
        loadImageList(url: sourceUrl)
    }
    
}
