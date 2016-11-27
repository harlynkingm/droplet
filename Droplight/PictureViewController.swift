//
//  PictureViewController.swift
//  Droplight
//
//  Created by MHK on 11/12/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit
import AVFoundation

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
        if segue.identifier == "ClosePicture" {
            if let destination = segue.destination as? CameraViewController {
                destination.l = self.l
            }
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
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
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
    
    func keyboardWillBeHidden(notification: NSNotification){
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
