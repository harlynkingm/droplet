//
//  ViewController.swift
//  Droplight
//
//  Created by MHK on 11/6/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, CameraDelegate {
    
    @IBOutlet weak var stillView: UIImageView!
    @IBOutlet weak var previewView: UIView!
    
    var preview : AVCaptureVideoPreviewLayer?
    
    var camera : CameraModel?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.establishVideoPreviewArea()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initializeCamera() {
        self.camera = CameraModel(sender: self)
    }
    
    func establishVideoPreviewArea() {
        if var videoPreview = self.preview {
            videoPreview = AVCaptureVideoPreviewLayer(session: self.camera!.session)
            videoPreview.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreview.frame = self.previewView.bounds
            self.previewView.layer.addSublayer(videoPreview)
        }
    }

    func cameraSessionConfigurationDidComplete() {
        self.camera!.startCamera()
    }
    
    func cameraSessionDidBegin() {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.previewView.alpha = 1.0
        })
    }
    
    func cameraSessionDidStop() {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.previewView.alpha = 0.0
        })
    }
}

