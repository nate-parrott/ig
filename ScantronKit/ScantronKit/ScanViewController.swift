//
//  ScanViewController.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/15/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

let HasEverGradedQuizDefaultsKey = "HasEverGradedQuizDefaultsKey"
let PostScanDelay = 1.0

class ScanViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanViewController.appBecameActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanViewController.appWillBecomeInactive), name: UIApplicationWillResignActiveNotification, object: nil)
        
        scanner = Scanner(cameraView: self.cameraView!)
        scanner!.onScannedPage = {
            page in
            AsyncOnMainQueue {
                self.infoController.addPage(page)
            }
        }
        if IS_SIMULATOR() {
            self.testShutterButton!.hidden = false
        }
        
        scanner!.onStatusChanged = {
            AsyncOnMainQueue {
                self.statusChanged()
            }
        }
        infoController.onStatusChanged = {
            AsyncOnMainQueue {
                self.statusChanged()
            }
        }
        infoController.onShowAdvisoryMessage = {
            (message: String) in
            AsyncOnMainQueue {
                self.statusChanged()
            }
        }
        
        UINib(nibName: "StatusView", bundle: nil).instantiateWithOwner(self, options: nil)
        view.addSubview(statusView)
        
        animator = UIDynamicAnimator(referenceView: view)
        
        statusView.backgroundColor = UIColor.clearColor()
        statusBackdrop = UIView()
        statusBackdrop.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        view.insertSubview(statusBackdrop, belowSubview: statusView)
        statusView.center = CGPointMake(view.width/2, view.height + statusView.height/2)
        
        viewDidLayoutSubviews()
        
        if DEBUGMODE() {
            cameraView!.backgroundColor = UIColor(white: 0.5, alpha: 1)
        }
        
        if SharedReachability.initialized {
            showUnreachableEdu = !SharedReachability.reachable
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged", name: kDefaultNetworkReachabilityChangedNotification, object: SharedReachability)
        
        if let device = cameraView!.captureDevice {
            flashButton.hidden = !device.torchAvailable
            kvoController.observe(device.torchAvailable, keyPath: "torchAvailable", options: []) {
                [weak self]
                (deviceChanged) in
                self!.flashButton.hidden = !device.torchAvailable
            }
        } else {
            flashButton.hidden = true
        }
    }
    
    lazy var kvoController: FBKVOController = {
        return FBKVOController(observer: self)
    }()
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBOutlet var cameraView: CameraView?
    @IBOutlet var testShutterButton: UIButton?
    @IBOutlet var savedQuizzesButton: UIButton!
    
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !SharedAPI().canScan() || !NSUserDefaults.standardUserDefaults().boolForKey("ShownInitialPaymentsMenu") {
            performSegueWithIdentifier("ShowPaymentsMenu", sender: nil)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "ShownInitialPaymentsMenu")
        } else {
            cameraView!.canRun = true
        }
    }
    
    func appBecameActive() {
        appIsActive = true
        updateScanConstantly()
    }
    func appWillBecomeInactive() {
        appIsActive = false
        updateScanConstantly()
    }
    
    var lastScannedPageClearTime: NSDate = NSDate.distantPast() as NSDate {
        didSet {
            updateScanConstantly()
            delay(PostScanDelay) {
                self.updateScanConstantly()
            }
        }
    }
    
    var appIsActive = true
    var vcIsVisible = false
    func updateScanConstantly() {
        let shouldScanConstantly = !IS_SIMULATOR() && appIsActive && vcIsVisible && (NSDate().timeIntervalSinceReferenceDate - lastScannedPageClearTime.timeIntervalSinceReferenceDate >= PostScanDelay)
        if shouldScanConstantly {
            scanner!.start()
        } else {
            scanner!.stop()
        }
    }
    var scanner: Scanner?
    
    @IBAction func testShutter() {
        let image = UIImage(named: "vr")
        PageExtraction().extract(image!) {
            imageOpt in
            if let image = imageOpt {
                let scanned = ScannedPage(image: image)
                let barcode = scanned.barcode
                print("Barcode is index \(barcode.index) and page # \(barcode.pageNum)")
                self.infoController.addPage(scanned)
            } else {
                print("Scan failed")
            }
        }
    }
    
    // MARK: quiz info controller
    var infoController = QuizInfoController()
    
    func statusChanged() {
        if (NSDate().timeIntervalSinceReferenceDate - self.lastScannedPageClearTime.timeIntervalSinceReferenceDate < PostScanDelay) {
            switch infoController.status {
            case .None:
                0
            default:
                // clear the status and return:
                infoController.clear()
                return;
            }
        }
        
        updateScanConstantly()
        crosshair.image = scanner!.status == Scanner.Status.PossibleScan ? UIImage(named: "Crosshair-on") : UIImage(named: "Crosshair-off")
        view.setNeedsLayout()
        switch infoController.status {
        case .Done:
            if let gradedItems = infoController.lastGradeForThisScan {
                let result = GenerateGradeForItemsWithResponses(gradedItems)
                pageStatusLabel.text = "\(result.points) / \(result.total)"
            } else if infoController.currentlyGrading {
                pageStatusLabel.text = "Grading..."
            } else {
                pageStatusLabel.text = "Scan Complete"
            }
            okayButton.enabled = true
        case .None:
            // do nothing
            if infoController.loadingCount > 0 {
                pageStatusLabel.text = "Loading..."
            }
            okayButton.enabled = false
        case .PartialScan(pages: let pages, total: let total):
            pageStatusLabel.text = NSString(format: NSLocalizedString("Page %i/%i", comment: ""), pages, total) as String
            okayButton.enabled = false
        }
    }
    
    // MARK: Layout
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let width: CGFloat = min(500, view.bounds.size.width)
        let height: CGFloat = 70
        statusView!.bounds = CGRectMake(0, 0, width, height)
        
        var statusVisible = false
        switch infoController.status {
        case .None:
            if infoController.loadingCount > 0 {
                statusVisible = true
            }
        case .PartialScan(pages: _, total: _):
            statusVisible = true
        case .Done:
            statusVisible = true
        }
        let y: CGFloat = statusVisible ? view.bounds.size.height - statusView!.bounds.size.height/2 : view.bounds.size.height + statusView!.bounds.size.height/2 + 20
        statusViewCenterPoint = CGPointMake(view.bounds.size.width/2, y)
        
        self.statusViewVisible = statusVisible
        
        statusBackdrop.frame = CGRectMake(0, view.bounds.size.height - statusView!.bounds.size.height, view.bounds.size.width, statusView!.bounds.size.height)
    }
    
    var statusViewCenterPoint: CGPoint = CGPointZero {
        willSet(val) {
            if val != statusViewCenterPoint {
                if let existing = statusViewPositioningBehavior {
                    animator!.removeBehavior(existing)
                }
                statusViewPositioningBehavior = UISnapBehavior(item: statusView!, snapToPoint: val)
                animator!.addBehavior(statusViewPositioningBehavior!)
                
                let alpha: CGFloat = (val == CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height - self.statusView.bounds.size.height/2)) ? 1 : 0
                self.statusBackdrop.animateAlphaTo(alpha, duration: 0.6)
            }
        }
    }

    var animator: UIDynamicAnimator?
    
    // MARK: Status view
    @IBOutlet var statusView: StatusView!
    var statusBackdrop: UIView!
    var statusViewPositioningBehavior: UISnapBehavior?
    @IBOutlet var pageStatusLabel: UILabel!
    @IBOutlet var okayButton: UIButton!
    
    @IBOutlet var crosshair: UIImageView!
    
    @IBAction func clearScannedPages() {
        Mixpanel.sharedInstance().track("ClearScannedPages")
        lastScannedPageClearTime = NSDate()
        infoController.clear()
    }
    
    @IBAction func acceptScannedQuiz() {
        // transparentScreenshot() // 
        
        if !SharedAPI().canScan() {
            performSegueWithIdentifier("ShowPaymentsMenu", sender: nil)
            return
        }
        
        Mixpanel.sharedInstance().track("AcceptScannedQuiz")
        
        if infoController.quiz != nil && infoController.status == QuizInfoController.Status.Done {
            let manualResponseTemplates = infoController.quiz!.getManuallyGradedResponseTemplates()
            if manualResponseTemplates.filter( { $0 != nil} ).count > 0 {
                let navController = storyboard!.instantiateViewControllerWithIdentifier("ManualResponseNavController") as! UINavigationController
                let manualResponseVC = navController.viewControllers.first! as! ManualResponseViewController
                manualResponseVC.setupWithItems(manualResponseTemplates, pages: infoController.pages, quiz: infoController.quiz!)
                navController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
                presentViewController(navController, animated: true, completion: nil)
                manualResponseVC.onFinished = {
                    (responseItems) in
                    self.infoController.manualResponseItems = responseItems
                }
                manualResponseVC.onDismissalAnimationCompleted = {
                    [weak self] in
                    self!.saveScannedQuiz()
                }
            } else {
                saveScannedQuiz()
            }
        }
    }
    
    func transparentScreenshot() {
        testShutterButton!.hidden = true
        cameraView!.backgroundColor = UIColor.clearColor()
        okayButton.adjustsImageWhenHighlighted = false
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIImagePNGRepresentation(image)!.writeToFile("/Users/nateparrott/Desktop/screen.png", atomically: true)
        UIGraphicsEndImageContext()
    }
    
    var justSavedQuizCount: Int = 0 {
        didSet {
            savedQuizzesButton.setTitle("\(justSavedQuizCount)", forState: UIControlState.Normal)
        }
    }
    
    func saveScannedQuiz() {
        
        SharedAPI().scansLeft = max(SharedAPI().scansLeft - 1, 0)
        
        let instance = infoController.createGradedQuizInstance()
        SharedAPI().uploadQuizInstances()
        
        // do animation:
        
        let gradeFlyingAnimatedView = pageStatusLabel.snapshotViewAfterScreenUpdates(false)
        view.addSubview(gradeFlyingAnimatedView)
        gradeFlyingAnimatedView.frame = view.convertRect(pageStatusLabel.bounds, fromView: pageStatusLabel)
        
        func scaleValues(values: [CGFloat]) -> [NSValue] {
            return values.map({ NSValue(CATransform3D: CATransform3DMakeScale($0, $0, $0)) })
        }

        let duration: NSTimeInterval = 0.5
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            gradeFlyingAnimatedView.removeFromSuperview()
            self.justSavedQuizCount++
        }
        let fly = CAKeyframeAnimation(keyPath: "position")
        fly.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        fly.removedOnCompletion = false
        fly.fillMode = kCAFillModeForwards
        let fromPos = gradeFlyingAnimatedView.center
        let toPos = savedQuizzesButton.center
        let controlPoint = CGPointMake(fromPos.x, toPos.y)
        let path = UIBezierPath()
        path.moveToPoint(fromPos)
        path.addQuadCurveToPoint(toPos, controlPoint: controlPoint)
        fly.path = path.CGPath
        fly.duration = duration
        gradeFlyingAnimatedView.layer.addAnimation(fly, forKey: "gradeFlyingAnimatedView")
        let growAndShrink = CAKeyframeAnimation(keyPath: "transform")
        growAndShrink.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        growAndShrink.removedOnCompletion = false
        growAndShrink.fillMode = kCAFillModeForwards
        growAndShrink.duration = duration
        growAndShrink.keyTimes = [0.0, 0.5, 1.0]
        growAndShrink.values = scaleValues([1, 1.5, 0.01])
        gradeFlyingAnimatedView.layer.addAnimation(growAndShrink, forKey: "growAndShrink")
        let growAndShrinkButton = CAKeyframeAnimation(keyPath: "transform")
        growAndShrinkButton.duration = duration
        growAndShrinkButton.keyTimes = [0.0, 0.8, 1.0]
        growAndShrinkButton.values = scaleValues([1, 1.2, 1])
        savedQuizzesButton.layer.addAnimation(growAndShrinkButton, forKey: "savedQuizzesButton")
        CATransaction.commit()
        
        pageStatusLabel.alpha = 0
        UIView.animateWithDuration(0.3, delay: duration + 0.5, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            self.pageStatusLabel.alpha = 1
        }) { (_) -> Void in
            
        }
        
        hasEverGradedQuiz = true
        lastScannedPageClearTime = NSDate()
        infoController.clear()
    }
    
    // MARK: Transitions
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowResults" {
            justSavedQuizCount = 0
        } else if segue.identifier == "ShowPaymentsMenu" {
            let paymentsVC = (segue.destinationViewController as! PaymentViewController)
            paymentsVC.onDismiss = {
                () in
                self.cameraView!.canRun = true
            }
        }
    }
    
    // MARK: Flash
    var flash: Bool = false {
        didSet {
            flashButton.selected = flash
            if let camera = cameraView!.captureDevice {
                do {
                    try camera.lockForConfiguration()
                    camera.torchMode = flash ? .On : .Off
                    camera.unlockForConfiguration()
                } catch _ {
                    
                }
            }
        }
    }
    @IBOutlet var flashButton: UIButton!
    @IBAction func toggleFlash() {
        flash = !flash
    }
    
    // MARK: Edu
    @IBOutlet var edu: UIView!
    @IBOutlet var eduLabel: UILabel!
    var hasEverGradedQuiz: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(HasEverGradedQuizDefaultsKey)
        }
        set(val) {
            NSUserDefaults.standardUserDefaults().setBool(val, forKey: HasEverGradedQuizDefaultsKey)
            updateEdu()
        }
    }
    var showUnreachableEdu: Bool = false {
        didSet {updateEdu()}
    }
    var statusViewVisible: Bool = false {
        didSet {updateEdu()}
    }
    func updateEdu() {
        var eduText: String? = nil
        if !statusViewVisible {
            if showUnreachableEdu {
                eduText = NSLocalizedString("Can't connect to the Internet.", comment: "")
            } else if !hasEverGradedQuiz {
                eduText = NSLocalizedString("Create quizzes on your computer at instagradeapp.com, then scan completed answer sheets here.", comment: "")
            }
        }
        if let text = eduText {
            eduLabel.text = text
        }
        edu.animateAlphaTo(eduText == nil ? 0 : 1, duration: 0.5)
    }
    
    func reachabilityChanged() {
        showUnreachableEdu = (SharedReachability.initialized && !SharedReachability.reachable)
    }
    
    
    // MARK: Rotation support
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        cameraView!.updateVideoOrientation()
    }
    
}
