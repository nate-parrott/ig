//
//  ScanViewController.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/15/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class ScanViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appBecameActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWillBecomeInactive", name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBOutlet var cameraView: CameraView?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        vcIsVisible = true
        updateScanConstantly()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        vcIsVisible = false
        updateScanConstantly()
    }
    
    func appBecameActive() {
        appIsActive = true
        updateScanConstantly()
    }
    func appWillBecomeInactive() {
        appIsActive = false
        updateScanConstantly()
    }
    
    #if arch(arm) || arch(arm64)
    let isSimulator = false
    #else
    let isSimulator = true
    #endif
    var appIsActive = true
    var vcIsVisible = false
    var isScanningConstantly = false
    func updateScanConstantly() {
        let shouldScanConstantly = !isSimulator && appIsActive && vcIsVisible
        if shouldScanConstantly && !isScanningConstantly {
            if !scanInProgress {
                snap()
            }
        } else {
            // stop scanning
        }
        isScanningConstantly = shouldScanConstantly
    }
    var scanInProgress = false
    
    @IBAction func snap() {
        if let output = cameraView!.stillImageOutput {
            let connection = cameraView!.stillImageOutput!.connections.first! as AVCaptureConnection
            cameraView!.stillImageOutput!.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { (sample: CMSampleBuffer!, error: NSError?) -> Void in
                let jpegData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sample)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                    let image = UIImage(data: jpegData)
                    self.handleImage(image)
                })
            })
        } else {
            if isSimulator {
                handleImage(UIImage(named: "1202652"))
            } else {
                dispatch_after(1 * NSEC_PER_SEC, dispatch_get_main_queue(), {
                    self.snap()
                })
            }
        }
    }
    
    func handleImage(image: UIImage) {
        let startTime = NSDate.timeIntervalSinceReferenceDate()
        extractScannedPage(image) {
            (pageOpt: ScannedPage?) in
            
            let elapsed = NSDate.timeIntervalSinceReferenceDate() - startTime
            println("\(elapsed) elapsed")
            
            if let page = pageOpt {
                let barcode = page.barcode
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SharedAPI().getQuizWithIndex(barcode.index) {
                        (quizOpt: Quiz?) in
                        if let quiz = quizOpt {
                            self.reportTestingResult("Got quiz: \(quiz.json)")
                        } else {
                            if self.isScanningConstantly && false { // TODO: remove this debugging stuff
                                self.done()
                            } else {
                                self.reportTestingResult("No quiz for barcode \(barcode.index)")
                            }
                        }
                    }
                })
            } else {
                if self.isScanningConstantly {
                    self.done()
                } else {
                    self.reportTestingResult("failure")
                }
            }
            
        }
    }
    
    func reportTestingResult(result: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let c = UIAlertController(title: "RESULT:", message: result, preferredStyle: UIAlertControllerStyle.Alert)
            c.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: { (_) -> Void in
                self.done()
            }))
            self.presentViewController(c, animated: true, completion: nil)
            println("RESULT: \n\(result)")
        })
    }
    
    func done() {
        if self.isScanningConstantly {
            self.snap()
        }
    }
    
}
