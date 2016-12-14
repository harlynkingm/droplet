//
//  ViewController.swift
//  Droplight
//
//  Created by MHK on 11/6/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit
import AVFoundation

/**
 Allows the user to use the device's camera to capture photos
 */
class CameraViewController: UIViewController {
    
    // MARK: - Initializers
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var focusPoint: UIImageView!
    @IBOutlet weak var notification: UIView!
    
    var session: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var effects : EffectsController = DataController.sharedData.effects
    var userLocation : LocationController? = DataController.sharedData.userLocation
    var browserImages : ImageLoader? = DataController.sharedData.browserImages
    var collectionImages : ImageLoader? = DataController.sharedData.collectionImages
    
    var prepImage : UIImage?
    
    // Decides whether to show the 'uploaded' notification
    var didUpload : Bool = false
    
    // MARK: - Setup Functions
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    /**
     Initializes browser and collection loading on load
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
        setupLocation()
        if (browserImages == nil){
            DataController.sharedData.browserImages = ImageLoader(url: "https://droplightapi.herokuapp.com/apiv1/local_feed")
        }
        if (collectionImages == nil){
            let deviceID = UIDevice.current.identifierForVendor?.uuidString as String!
            DataController.sharedData.collectionImages = ImageLoader(url: "https://droplightapi.herokuapp.com/apiv1/collection?device=\(deviceID!)")
        }
        notification.transform = notification.transform.translatedBy(x: 0, y: -200)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        previewLayer!.frame = previewView.bounds
        CATransaction.commit()
        effects.addDefaultShadow(view: captureButton)
        effects.addDefaultShadow(view: profileButton)
        effects.addDefaultShadow(view: locationButton)
        if (didUpload){
            showNotification()
        }
    }
    
    /**
     Pauses the camera session
     */
    override func viewWillDisappear(_ animated: Bool) {
        if (self.session?.isRunning)! {
            self.session?.stopRunning()
        }
        super.viewWillDisappear(animated)
    }
    
    /**
     Initializes the camera capture session
     */
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        // Start capture session
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSessionPreset1920x1080
        
        // Select camera
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // Prepare input
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
            // Move on if back camera exists
            if session!.canAddInput(input){
                session!.addInput(input)
                stillImageOutput = AVCaptureStillImageOutput()
                stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                // Move on if you can add image output
                if session!.canAddOutput(stillImageOutput){
                    session!.addOutput(stillImageOutput)
                    previewLayer = AVCaptureVideoPreviewLayer(session: session)
                    previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                    previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                    previewView.layer.addSublayer(previewLayer!)
                    session!.startRunning()
                }
            }
        } catch {
            input = nil
            print("ERROR")
            print(error.localizedDescription)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     Sends the captured image to the new view controller
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier!){
        case "TakePicture":
            if let destination = segue.destination as? PictureViewController {
                destination.currentImage = self.prepImage
            }
            break
        default:
            break
        }
    }
    
    /**
     Sets up a gesture recognizer to snap a photo on two taps
     */
    func setupGestures(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(snapPhoto))
        tap.numberOfTapsRequired = 2
        previewView.addGestureRecognizer(tap)
    }
    
    /**
     Sets up the location controller if it has not been initialized
     */
    func setupLocation(){
        if userLocation == nil {
            DataController.sharedData.userLocation = LocationController()
        }
    }
    
    // MARK: - User Actions
    
    /**
     Sets the zoom of the camera based on touch movements
     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchPoint = touches.first {
            let yDiff = touchPoint.previousLocation(in: previewView).y - touchPoint.location(in: previewView).y
            setZoom(distance: yDiff)
        }
    }
    
    /**
     Snaps a photo from the camera view and begins the segue to the picture view
     */
    @IBAction func snapPhoto () {
        if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo){
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (sampleBuffer, error) -> Void in
                if sampleBuffer != nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProvider(data: imageData as! CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                    let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                    self.prepImage = image
                    self.performSegue(withIdentifier: "TakePicture", sender: self)
                }
            })
        }
    }
    
    @IBAction func unwindToViewController (sender: UIStoryboardSegue){ }
    
    /**
     Adjsuts a shadow to lessed when a finger is pressed on a button
     */
    @IBAction func depressButton (sender: UIButton){
        effects.adjustShadow(view: sender, newOffset: CGSize(width: 0, height: 1))
    }
    
    /**
     Adjusts the shadow to grow when a finger is lifted
     */
    @IBAction func compressButton (sender: UIButton){
        effects.adjustShadow(view: sender, newOffset: CGSize(width: 0, height: 3))
    }
    
    /**
     Sets a tap for focusing and exposing using a gesture recognizer
     */
    @IBAction private func focusAndExposeTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let devicePoint = self.previewLayer?.captureDevicePointOfInterest(for: gestureRecognizer.location(in: gestureRecognizer.view))
        focusPoint.layer.removeAllAnimations()
        focusPoint.center = gestureRecognizer.location(in: view)
        focusPoint.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        focusPoint.alpha = 1
        // Does a small animation after tapping
        UIView.animate(withDuration: 0.2, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
            self.focusPoint.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: { (done : Bool) in
            UIView.animate(withDuration: 0.2, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
                self.focusPoint.alpha = 0
            })
        })
        focus(with: .autoFocus, exposureMode: .autoExpose, at: devicePoint!, monitorSubjectAreaChange: true)
    }
    
    // MARK: - Camera Controls
    
    /**
     Focuses the camera and sets the exposure based on a tap
     */
    private func focus(with focusMode: AVCaptureFocusMode, exposureMode: AVCaptureExposureMode, at devicePoint: CGPoint, monitorSubjectAreaChange: Bool) {
        let input = self.session?.inputs.first as? AVCaptureDeviceInput
        if let device = input?.device {
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }
                
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }
                
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                if device.isExposureModeSupported(.continuousAutoExposure){
                    device.exposureMode = .continuousAutoExposure
                }
                device.unlockForConfiguration()
            }
            catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
    
    /**
     Sets the zoom using a vertical finger movement distance
     */
    func setZoom(distance: CGFloat){
        let input = self.session?.inputs.first as? AVCaptureDeviceInput
        do {
            try input?.device.lockForConfiguration()
        } catch {
            return
        }
        let min = CGFloat(1.0)
        let max = (input?.device.activeFormat.videoMaxZoomFactor)!
        let newZoom = (input?.device.videoZoomFactor)! + (distance * 0.008)
        input?.device.videoZoomFactor = CGFloat.minimum(CGFloat.maximum(min, newZoom), max)
        input?.device.unlockForConfiguration()
    }
    
    // MARK: - Notification Display
    
    /**
     Animates the uploaded notification down from the top of the screen
     */
    func showNotification(){
        didUpload = false
        UIView.animate(withDuration: 0.7, delay: 0, options: [UIViewAnimationOptions.curveEaseIn], animations: {
            self.notification.transform = self.notification.transform.translatedBy(x: 0, y: 200)
        }, completion: { (done : Bool) in
            UIView.animate(withDuration: 0.7, delay: 3, options: [UIViewAnimationOptions.curveEaseIn], animations: {
                self.notification.transform = self.notification.transform.translatedBy(x: 0, y: -200)
            })
        })
    }

}

