//
//  CameraModel.swift
//  Droplight
//
//  Created by MHK on 11/6/16.
//  Copyright © 2016 MHK. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

@objc protocol CameraDelegate {
    func cameraSessionConfigurationDidComplete()
    func cameraSessionDidBegin()
    func cameraSessionDidStop()
}

class CameraModel: NSObject {
    weak var delegate : CameraDelegate?
    
    var session: AVCaptureSession!
    var sessionQueue: DispatchQueue!
    var stillImageOutput: AVCaptureStillImageOutput?
    
    init(sender: AnyObject) {
        super.init()
        self.delegate = sender as? CameraDelegate
        self.setObservers()
        self.initializeSession()
    }
    
    func initializeSession() {
        self.session = AVCaptureSession()
        self.session.sessionPreset = AVCaptureSessionPresetPhoto
        self.sessionQueue = DispatchQueue(label: "camera session", attributes: [])
        
        self.sessionQueue.async {
            self.session.beginConfiguration()
            self.addVideoInput()
            self.addStillImageOutput()
            self.session.commitConfiguration()
            
            DispatchQueue.main.async {
                NSLog("Session initialization did complete")
                self.delegate?.cameraSessionConfigurationDidComplete()
            }
        }
    }
    
    deinit {
        self.removeObservers()
    }
    
    func startCamera() {
        self.sessionQueue.async {
            self.session.startRunning()
        }
    }
    
    func stopCamera() {
        self.sessionQueue.async {
            self.session.stopRunning()
        }
    }
    
    func captureStillImage(_ completed: @escaping (_ image: UIImage?) -> Void) {
        if let imageOutput = self.stillImageOutput {
            self.sessionQueue.async(execute: { () -> Void in
                var videoConnection: AVCaptureConnection?
                for connection in imageOutput.connections {
                    let c = connection as! AVCaptureConnection
                    
                    for port in c.inputPorts {
                        let p = port as! AVCaptureInputPort
                        if p.mediaType == AVMediaTypeVideo {
                            videoConnection = c
                            break
                        }
                    }
                    
                    if videoConnection != nil {
                        break
                    }
                }
                
                if videoConnection != nil {
                    imageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (imageSampleBuffer: CMSampleBuffer!, error) -> Void in
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                        let image: UIImage? = UIImage(data: imageData!)!
                        
                        DispatchQueue.main.async {
                            completed(image: image)
                        }
                    })
                } else {
                    DispatchQueue.main.async {
                        completed(nil)
                    }
                }
            })
        }
    }
    
    func addVideoInput() {
        let device: AVCaptureDevice = self.deviceWithMediaTypeWithPosition(AVMediaTypeVideo as NSString, position: AVCaptureDevicePosition.back)
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if self.session.canAddInput(input){
                self.session.addInput(input)
            }
        } catch {
            print(error)
        }
    }
    
    func addStillImageOutput() {
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        if self.session.canAddOutput(stillImageOutput) {
            session.addOutput(stillImageOutput)
        }
    }
    
    func deviceWithMediaTypeWithPosition(_ mediaType: NSString, position: AVCaptureDevicePosition) -> AVCaptureDevice {
        let devices: NSArray = AVCaptureDevice.devices(withMediaType: mediaType as String) as NSArray
        var captureDevice: AVCaptureDevice = devices.firstObject as! AVCaptureDevice
        for device in devices {
            let d = device as! AVCaptureDevice
            if d.position == position {
                captureDevice = d
                break
            }
        }
        return captureDevice
    }
    
    func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(CameraModel.sessionDidStart(_:)), name: NSNotification.Name.AVCaptureSessionDidStartRunning, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CameraModel.sessionDidStop(_:)), name: NSNotification.Name.AVCaptureSessionDidStopRunning, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func sessionDidStart(_ notification: Notification) {
        DispatchQueue.main.async {
            NSLog("Session did start")
            self.delegate?.cameraSessionDidBegin()
        }
    }
    
    func sessionDidStop(_ notification: Notification) {
        DispatchQueue.main.async {
            NSLog("Session did stop")
            self.delegate?.cameraSessionDidStop()
        }
    }
}
