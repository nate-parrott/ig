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
        
        scanner = Scanner(cameraView: self.cameraView!)
        scanner!.onScannedPage = {
            page in
            AsyncOnMainQueue {
                self.infoController.addPage(page)
            }
            /*let barcode = page.barcode
            let alert = UIAlertController(title: "Scanned", message: "Barcode is index \(barcode.index) and page # \(barcode.pageNum)", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)*/
        }
        if IS_SIMULATOR() {
            self.testShutterButton!.hidden = false
        }
        
        scanner!.onStatusChanged = {
            AsyncOnMainQueue {
                self.updateStatusMessage()
            }
        }
        infoController.onStatusChanged = {
            AsyncOnMainQueue {
                self.updateStatusMessage()
            }
        }
        infoController.onShowAdvisoryMessage = {
            (message: String) in
            AsyncOnMainQueue {
                self.lastMessage = message
                self.lastMessageTime = NSDate.timeIntervalSinceReferenceDate()
                self.updateStatusMessage()
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBOutlet var cameraView: CameraView?
    @IBOutlet var testShutterButton: UIButton?
    
    // MARK: Continuous scanning
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
    
    var appIsActive = true
    var vcIsVisible = false
    func updateScanConstantly() {
        let shouldScanConstantly = !IS_SIMULATOR() && appIsActive && vcIsVisible
        if shouldScanConstantly {
            scanner!.start()
        } else {
            scanner!.stop()
        }
    }
    var scanner: Scanner?
    
    @IBAction func testShutter() {
        let image = UIImage(named: "1202652")
        PageExtraction().extract(image) {
            imageOpt in
            if let image = imageOpt {
                let scanned = ScannedPage(image: image)
                let barcode = scanned.barcode
                println("Barcode is index \(barcode.index) and page # \(barcode.pageNum)")
            } else {
                println("Scan failed")
            }
        }
    }
    
    // MARK: quiz info controller
    var infoController = QuizInfoController()
    
    @IBAction func clear() {
        infoController.clear()
    }
    
    @IBOutlet var statusLabel: UILabel?
    
    func updateStatusMessage() {
        var s = "\(scanner!.status)\n\(infoController.status)"
        if infoController.loadingCount > 0 {
            s += " (loading)"
        }
        if NSDate.timeIntervalSinceReferenceDate() - lastMessageTime < 5 {
            s += "\n" + lastMessage
        }
        self.statusLabel!.text = s
    }
    
    var lastMessage: String = ""
    var lastMessageTime: NSTimeInterval = 0.0
}
