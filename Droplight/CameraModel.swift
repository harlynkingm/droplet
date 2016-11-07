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
    var sessionQueue: dispatch_queue_t!
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
        self.sessionQueue = dispatch_queue_create("camera session", DISPATCH_QUEUE_SERIAL)
        
        dispatch_async(self.sessionQueue) {
            self.session.beginConfiguration()
            self.addVideoInput()
            self.addStillImageOutput()
            self.session.commitConfiguration()
            
            dispatch_async(dispatch_get_main_queue()) {
                NSLog("Session initialization did complete")
                self.delegate?.cameraSessionConfigurationDidComplete()
            }
        }
    }
    
    deinit {
        self.removeObservers()
    }
    
    func startCamera() {
        dispatch_async(self.sessionQueue) {
            self.session.startRunning()
        }
    }
    
    func stopCamera() {
        dispatch_async(self.sessionQueue) {
            self.session.stopRunning()
        }
    }
    
    func captureStillImage(completed: (image: UIImage?) -> Void) {
        if let imageOutput = self.stillImageOutput {
            dispatch_async(self.sessionQueue, { () -> Void in
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
                    imageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageSampleBuffer: CMSampleBufferRef!, error) -> Void in
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                        let image: UIImage? = UIImage(data: imageData!)!
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            completed(image: image)
                        }
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        completed(image: nil)
                    }
                }
            })
        }
    }
    
    func addVideoInput() {
        let device: AVCaptureDevice = self.deviceWithMediaTypeWithPosition(AVMediaTypeVideo, position: AVCaptureDevicePosition.Back)
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
    
    func deviceWithMediaTypeWithPosition(mediaType: NSString, position: AVCaptureDevicePosition) -> AVCaptureDevice {
        let devices: NSArray = AVCaptureDevice.devicesWithMediaType(mediaType as String)
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Camera.sessionDidStart(_:)), name: AVCaptureSessionDidStartRunningNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Camera.sessionDidStop(_:)), name: AVCaptureSessionDidStopRunningNotification, object: nil)
    }
    
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func sessionDidStart(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            NSLog("Session did start")
            self.delegate?.cameraSessionDidBegin()
        }
    }
    
    func sessionDidStop(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            NSLog("Session did stop")
            self.delegate?.cameraSessionDidStop()
        }
    }
}
