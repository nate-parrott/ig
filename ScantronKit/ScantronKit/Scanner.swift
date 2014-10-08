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
        if let c = cameraView.captureDevice {
            kvoController.observe(c, keyPath: "adjustingFocus", options: nil, action: "autofocusStatusChanged")
        }
    }
    // MARK: Status
    enum Status : Printable {
        case Off
        case On
        case PossibleScan
        
        var description : String {
            switch self {
            case .Off: return "Off"
            case .On: return "On"
            case .PossibleScan: return "PossibleScan"
            }
        }
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
    lazy var kvoController: FBKVOController = {
        return FBKVOController(observer: self)
    }()
    
    func start() {
        stopping = false
        if status == .Off {
            status = .On
            scanNow()
        }
    }
    
    func stop() {
        stopping = true
    }
    
    // MARK: Scanning
    var cameraView: CameraView
    
    private func scanNow() {
        waitingOnAutofocus = false
        if let output = cameraView.stillImageOutput {
            let camera = cameraView.captureDevice!
            if camera.adjustingFocus {
                waitingOnAutofocus = true
                return
            }
            let connection = cameraView.stillImageOutput!.connections.first! as AVCaptureConnection
            cameraView.stillImageOutput!.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { (sample: CMSampleBuffer!, error: NSError?) -> Void in
                if sample == nil {
                    println("ERROR: \(error)")
                    self.scanALittleLater()
                } else {
                    let jpegData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sample)
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                        let image = UIImage(data: jpegData)
                        self.handleImage(image)
                    })
                }
            })
        } else {
            scanALittleLater()
        }
    }
    
    func scanALittleLater() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            if self.stopping {
                self.status = .Off
            } else {
                self.scanNow()
            }
        }
    }
    
    private var waitingOnAutofocus = false
    @objc func autofocusStatusChanged() {
        if let c = cameraView.captureDevice {
            if !c.adjustingFocus && waitingOnAutofocus {
                scanNow()
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
                let _ = page.blurriness // cause it to compute the lazy prop (so we don't do it later on the main thread)
                dispatch_async(dispatch_get_main_queue()) {
                    if let callback = self.onScannedPage {
                        callback(page)
                    }
                }
            } else {
                self.status = .On
            }
            self.doneWithSingleScan()
        }
    }
    
    private func doneWithSingleScan() {
        // called on background queue:
        let elapsed = NSDate.timeIntervalSinceReferenceDate() - startTime
        // println("\(elapsed) elapsed")
        
        dispatch_async(dispatch_get_main_queue()) {
            if self.stopping {
                self.status = .Off
            } else {
                self.scanNow()
            }
        }
    }
}
