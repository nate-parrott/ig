//
//  QRCodeScannerViewController.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/15/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class QRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cameraView!.metadataObjectsDelegate = self
    }
    
    var alreadyScannedCodeAndTransitionedToLoginScreen = false
    var receivedAuthUrl: NSURL? = nil
    
    override func viewWillAppear(animated: Bool) {
        alreadyScannedCodeAndTransitionedToLoginScreen = false
    }
    
    @IBOutlet var cameraView: CameraView?
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        for object in metadataObjects {
            if let code = object as? AVMetadataMachineReadableCodeObject {
                if !alreadyScannedCodeAndTransitionedToLoginScreen {
                    receivedAuthUrl = NSURL(string: code.stringValue)
                    alreadyScannedCodeAndTransitionedToLoginScreen = true
                    performSegueWithIdentifier("Done", sender: nil)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "Done" {
            let destination = segue.destinationViewController as LoginConfirmedViewController
            destination.authUrl = receivedAuthUrl
        }
    }
}


