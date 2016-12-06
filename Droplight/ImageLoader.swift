//
//  ImageLoader.swift
//  Droplet
//
//  Created by MHK on 12/5/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import Alamofire
import UIKit
import Foundation

protocol ImageLoaderDelegate : class {
    func didLoadImage(sender: ImageLoader, newImage: UIImage)
}

class ImageLoader : NSObject {
    
    weak var delegate : ImageLoaderDelegate?
    
    var sourceUrl : String
    
    var imageQueue : [String]
    var loadedImages : [UIImage]
    var seenImages : Set<String>
    
    init(url: String) {
        sourceUrl = url
        loadedImages = []
        imageQueue = []
        seenImages = Set<String>()
        super.init()
        loadImageList(url: url)
    }
    
    func loadImageList(url: String){
        Alamofire.request(url).responseJSON{ response in
            do {
                let parsedData = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String:Any]
                let images = parsedData["images"] as! [String]
                for imageUrl in images {
                    if (!self.seenImages.contains(imageUrl)){
                        self.imageQueue.append(imageUrl)
                        self.seenImages.insert(imageUrl)
                    }
                }
                self.processQueue()
            } catch {
                print(error)
            }
        }
    }
    
    func processQueue(){
        if (imageQueue.count > 0){
            let url : String = imageQueue.popLast()!
            Alamofire.request(url).response { response in
                let newImage : UIImage! = UIImage(data: response.data!, scale: 1)
                self.addImage(image: newImage)
                self.processQueue()
            }
        }
    }
    
    func addImage(image : UIImage){
        loadedImages.append(image)
        if let d = delegate {
            d.didLoadImage(sender: self, newImage: image)
        }
    }
    
    func refresh(){
        loadImageList(url: sourceUrl)
    }
    
}
