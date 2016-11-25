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
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
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
        e.addShadow(view: locationText, opacity: 0.5, offset: CGSize(width: 0, height: 0), radius: 5.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loading.stopAnimating()
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
    
    @IBAction func uploadImage() {
        self.loading.startAnimating()
        self.loading.hidesWhenStopped = true
        if let image : UIImage = currentImage {
            if let data : Data = UIImageJPEGRepresentation(image, 0.9) {
                var request = URLRequest(url: URL(string: "http://128.237.176.200:3000/api/image")!)
                request.httpMethod = "POST"
                let base64String = data.base64EncodedString()
                let params : [String: String] = [ "content_type": "image/jpeg", "filename":"test.jpg", "imageData":base64String]
                request.httpBody = paramSerialization(params: params).data(using: String.Encoding.utf8);
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        print("error=\(error)")
                        return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        print("response = \(response)")
                    }
                    
                    let responseString = String(data: data, encoding: .utf8)
                    print("responseString = \(responseString)")
                    self.loading.stopAnimating()
                }
                task.resume()
            }
        }
    }
    
    func paramSerialization (params: [String: String]) -> String{
        return params.flatMap {"\($0.0)=\($0.1)&"}.reduce("", +)
    }
    
}
