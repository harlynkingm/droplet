//
//  ViewController.swift
//  Droplight
//
//  Created by MHK on 11/6/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    var session: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var e : EffectsController = EffectsController()
    var l : LocationController?
    
    var prepImage : UIImage?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
        setupLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        previewLayer!.frame = previewView.bounds
        CATransaction.commit()
        e.blurView(view: captureButton, radius: captureButton.bounds.width/2)
        e.blurView(view: profileButton, radius: 20)
        e.blurView(view: locationButton, radius: 20)
        locationButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
    }
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TakePicture" {
            if let destination = segue.destination as? PictureViewController {
                destination.currentImage = self.prepImage
                destination.l = self.l
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchPoint = touches.first {
            let yDiff = touchPoint.previousLocation(in: previewView).y - touchPoint.location(in: previewView).y
            setZoom(distance: yDiff)
        }
    }
    
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
        //input?.device.ramp(toVideoZoomFactor: CGFloat.minimum(CGFloat.maximum(min, newZoom), max), withRate: 10.0)
        input?.device.videoZoomFactor = CGFloat.minimum(CGFloat.maximum(min, newZoom), max)
        input?.device.unlockForConfiguration()
    }
    
    func setupGestures(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(snapPhoto))
        tap.numberOfTapsRequired = 2
        previewView.addGestureRecognizer(tap)
    }
    
    func setupLocation(){
        if l == nil {
            l = LocationController()
        }
    }
    
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
    
}

