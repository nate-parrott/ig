//
//  Scanner.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/19/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class Scanner: NSObject {
    init(cameraView: CameraView) {
        self.cameraView = cameraView
        super.init()
    }
    // MARK: Status
    enum Status {
        case Off
        case On
        case PossibleScan
    }
    private var stopping = false
    private(set) var status: Status = Status.Off {
        didSet {
            if let callback = onStatusChanged {
                callback()
            }
        }
    }
    var onStatusChanged: (() -> ())?
    var onScannedPage: (ScannedPage -> ())?
    
    func start() {
        stopping = false
        if status == .Off {
            scanNow()
        }
    }
    
    func stop() {
        stopping = true
    }
    
    // MARK: Scanning
    var cameraView: CameraView
    
    private func scanNow() {
        status = .On
        if let output = cameraView.stillImageOutput {
            let connection = cameraView.stillImageOutput!.connections.first! as AVCaptureConnection
            cameraView.stillImageOutput!.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { (sample: CMSampleBuffer!, error: NSError?) -> Void in
                let jpegData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sample)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                    let image = UIImage(data: jpegData)
                    self.handleImage(image)
                })
            })
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                if self.stopping {
                   self.status = .Off
                } else {
                    self.scanNow()
                }
            }
        }
    }
    
    private var startTime: NSTimeInterval = 0
    private func handleImage(image: UIImage) {
        // called on background queue
        startTime = NSDate.timeIntervalSinceReferenceDate()
        PageExtraction().extract(image) {
            extractedImageOpt in
            if let extractedImage = extractedImageOpt {
                dispatch_async(dispatch_get_main_queue()) {
                    self.status = .PossibleScan
                }
                let page = ScannedPage(image: extractedImage)
                dispatch_async(dispatch_get_main_queue()) {
                    if let callback = self.onScannedPage {
                        callback(page)
                    }
                }
            }
            self.doneWithSingleScan()
        }
    }
    
    private func doneWithSingleScan() {
        // called on background queue:
        let elapsed = NSDate.timeIntervalSinceReferenceDate() - startTime
        println("\(elapsed) elapsed")
        
        dispatch_async(dispatch_get_main_queue()) {
            self.status = .Off
            if !self.stopping {
                self.scanNow()
            }
        }
    }
}
