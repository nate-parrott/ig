//
//  CameraView.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/15/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class CameraView: UIView {
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(newWindow)
        running = (newWindow != nil)
    }
    
    var running: Bool = false {
        willSet(newVal) {
            if newVal != running {
                if newVal {
                    startRunning()
                } else {
                    stopRunning()
                }
            }
        }
    }
    
    var captureDevice: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var stillImageOutput: AVCaptureStillImageOutput?
    var metadataOutput: AVCaptureMetadataOutput?
    
    // MARK: setup
    
    func startRunning() {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted) -> Void in
            AsyncOnMainQueue() {
                if let p = self.permissionDialog {
                    p.hidden = granted
                }
                if granted {
                    self.actuallyStartRunning()
                }
            }
        })
    }
    
    func actuallyStartRunning() {
        if let device = getDevice() {
            captureDevice = device
            self.configureCamera(captureDevice!)
            captureSession = AVCaptureSession()
            if captureSession!.canSetSessionPreset(AVCaptureSessionPresetPhoto) {
                captureSession!.sessionPreset = AVCaptureSessionPreset1920x1080
            }
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            stillImageOutput = AVCaptureStillImageOutput()
            captureSession!.addOutput(stillImageOutput!)
            let captureDeviceInput = AVCaptureDeviceInput(device: captureDevice!, error: nil)
            captureSession!.addInput(captureDeviceInput)
            layer.addSublayer(previewLayer!)
            self.setNeedsLayout()
            
            if let metadataDelegate = metadataObjectsDelegate {
                metadataOutput = AVCaptureMetadataOutput()
                captureSession!.addOutput(metadataOutput!)
                metadataOutput!.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
                metadataOutput!.setMetadataObjectsDelegate(metadataDelegate, queue: dispatch_get_main_queue())
            }
            
            updateVideoOrientation()
            
            captureSession!.startRunning()
        }
    }
    
    func getDevice() -> AVCaptureDevice? {
        for device in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as [AVCaptureDevice] {
            if device.position == AVCaptureDevicePosition.Back {
                return device
            }
        }
        return nil
    }
    
    func configureCamera(camera: AVCaptureDevice) {
        if camera.lockForConfiguration(nil) {
            if camera.autoFocusRangeRestrictionSupported {
                camera.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestriction.Near
            }
            if camera.lowLightBoostSupported {
                camera.automaticallyEnablesLowLightBoostWhenAvailable = true
            }
            camera.unlockForConfiguration()
        }
    }
    
    // MARK: teardown
    
    func stopRunning() {
        if let session = captureSession {
            session.stopRunning()
            captureDevice = nil
            captureSession = nil
            previewLayer = nil
            stillImageOutput = nil
            metadataOutput = nil
        }
    }
    
    // MARK: layout
    override func layoutSubviews() {
        super.layoutSubviews()
        if let p = previewLayer {
            p.frame = bounds
        }
    }
    
    func updateVideoOrientation() {
        if let c = previewLayer?.connection {
            switch UIDevice.currentDevice().orientation {
            case .Portrait: c.videoOrientation = AVCaptureVideoOrientation.Portrait
            case .PortraitUpsideDown: c.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
            case .LandscapeLeft: c.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
            case .LandscapeRight: c.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
            default: 0
            }
        }
    }
    
    // MARK: metadata output
    @IBOutlet var metadataObjectsDelegate: AVCaptureMetadataOutputObjectsDelegate?
    
    // MARK: Permissions dialog
    @IBOutlet var permissionDialog: UIView?
    @IBAction func openSettings() {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString))
    }
}
