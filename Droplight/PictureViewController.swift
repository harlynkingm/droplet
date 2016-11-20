//
//  PictureViewController.swift
//  Droplight
//
//  Created by MHK on 11/12/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit
import AVFoundation

class PictureViewController: UIViewController, LocationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var locationText: UILabel!
    
    var currentImage : UIImage?
    
    var e: EffectsController = EffectsController()
    var l: LocationController?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        l?.delegate = self
        updateLocationText()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        e.blurView(view: uploadButton, radius: uploadButton.bounds.width/2)
        e.blurView(view: closeButton, radius: 20)
        e.blurView(view: saveButton, radius: 20)
        //e.blurView(view: locationText, radius: 2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateImage()
    }
    
    func updateImage() {
        if let image : UIImage = currentImage {
            imageView.image = image
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ClosePicture" {
            if let destination = segue.destination as? CameraViewController {
                destination.l = self.l
            }
        }
    }
    
    @IBAction func saveImage() {
        if let image : UIImage = currentImage {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_:didFinishSavingWithError: contextInfo:)), nil)
        }
    }
    
    func imageSaved(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            saveButton.setImage(UIImage(named: "check"), for: UIControlState.normal)
            saveButton.contentEdgeInsets = UIEdgeInsetsMake(9, 9, 5, 4)
        }
    }
    
    func updateLocationText() {
        if let location = l {
            if let placemark = location.placemark {
                if let sublocality = placemark.subLocality {
                    locationText.text = sublocality + ", " + placemark.locality!
                } else {
                    locationText.text = placemark.locality! + ", " + placemark.administrativeArea!
                }
            }
        }
    }
    
    func didGetLocation(sender: LocationController) {
        updateLocationText()
    }
    
}
