//
//  PictureViewController.swift
//  Droplight
//
//  Created by MHK on 11/12/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class PictureViewController: UIViewController, LocationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var locationText: UILabel!
    @IBOutlet weak var locationBg: UIView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var caption: UITextField!
    
    var currentImage : UIImage?
    
    var e: EffectsController = EffectsController()
    var l: LocationController?
    var i: ImageLoader?
    
    var locationSharing : Bool = true
    var captionBottom: CGFloat = CGFloat(0)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        l?.delegate = self
        caption.delegate = self
        updateLocationText()
        setupGestures()
        registerForKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        e.addShadow(view: uploadButton, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
        e.addShadow(view: closeButton, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
        e.addShadow(view: saveButton, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
        e.addShadow(view: locationButton, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
        e.addShadow(view: textButton, opacity: 1.0, offset: CGSize(width: 0, height: 3), radius: 0, color: UIColor(white:0.75, alpha:1.0))
        caption.layer.cornerRadius = caption.bounds.height/2
        locationBg.layer.cornerRadius = locationBg.bounds.height/2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        deregisterFromKeyboardNotifications()
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
        if let destination = segue.destination as? CameraViewController {
            destination.l = self.l
            destination.i = self.i
        }
    }
    
    @IBAction func saveImage() {
        if let image : UIImage = currentImage {
            self.loading.startAnimating()
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_:didFinishSavingWithError: contextInfo:)), nil)
        }
    }
    
    func imageSaved(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        self.loading.stopAnimating()
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            saveButton.setImage(UIImage(named: "check"), for: UIControlState.normal)
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
        let deviceID = UIDevice.current.identifierForVendor?.uuidString as String!
        let captionText = self.caption.text!
        if let image : UIImage = currentImage {
            if let data : Data = UIImageJPEGRepresentation(image, 0.0) {
                let base64 : String = data.base64EncodedString() // Image data to encoded string
                let stringData : Data = base64.data(using: String.Encoding.utf8)! as Data // String to Data
                Alamofire.upload(
                    multipartFormData: { multipartFormData in
                        multipartFormData.append(stringData, withName: "imageData")
                        multipartFormData.append("\(0.00)".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName :"latitude")
                        multipartFormData.append("\(0.00)".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName :"longitude")
                        multipartFormData.append("\(deviceID)".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName :"deviceID")
                        multipartFormData.append(captionText.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName :"caption")
                },
                    to: "https://droplightapi.herokuapp.com/apiv1/upload",
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .success(let upload, _, _):
                            upload.responseJSON { response in
                                //let decodeString : String = NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue) as! String // Data to encoded string
                                //let imageData : Data = NSData(base64Encoded: decodeString) as! Data // Encoded string to data
                                //self.imageView.image = UIImage(data: imageData)
                                print(NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue) as! String)
                                self.loading.stopAnimating()
                                self.performSegue(withIdentifier: "UploadPicture", sender: self)
                            }
                        case .failure(let encodingError):
                            print(encodingError)
                        }
                    }
                )
            }
        }
    }
    
    @IBAction func toggleLocation() {
        if (locationSharing){
            locationButton.setImage(UIImage(named: "location_off"), for: UIControlState.normal)
            locationText.isHidden = true
            locationBg.isHidden = true
        } else {
            locationButton.setImage(UIImage(named: "location_on"), for: UIControlState.normal)
            locationText.isHidden = false
            locationBg.isHidden = false
        }
        locationSharing = !locationSharing
    }
    
    func setupGestures(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapBackground))
        self.view.addGestureRecognizer(tap)
    }
    
    func tapBackground(){
        if (caption.isHidden){
            toggleText()
        } else {
            self.view.endEditing(true)
        }
    }
    
    func registerForKeyboardNotifications(){
        captionBottom = self.caption.frame.minY
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification){
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.origin.y
        self.caption.transform = self.caption.transform.translatedBy(x: 0, y: -1 * self.caption.frame.origin.y)
        UIView.animate(withDuration: 0.4, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
            self.caption.transform = self.caption.transform.translatedBy(x: 0, y: keyboardSize! - self.caption.frame.height)
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tapBackground()
        return false
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        if self.caption.text == "" {
            toggleText()
        }
        self.caption.transform = self.caption.transform.translatedBy(x: 0, y: -1 * self.caption.frame.origin.y)
        UIView.animate(withDuration: 0.4, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
            self.caption.transform = self.caption.transform.translatedBy(x: 0, y: self.captionBottom)
        })
    }
    
    @IBAction func toggleText(){
        self.caption.isHidden = !self.caption.isHidden
        if !self.caption.isHidden {
            self.caption.becomeFirstResponder()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var text = textField.text as NSString? else { return true }
        text = text.replacingCharacters(in: range, with: string) as NSString
        let textSize : CGSize = text.size(attributes: [NSFontAttributeName: textField.font!])
        return (textSize.width < textField.bounds.size.width - 30) ? true : false;
    }
    
}
