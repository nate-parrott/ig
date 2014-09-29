//
//  ScanViewController.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/15/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

let HasEverGradedQuizDefaultsKey = "HasEverGradedQuizDefaultsKey"

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
        
        savedQuizzesButton.layer.borderWidth = 2
        savedQuizzesButton.layer.cornerRadius = savedQuizzesButton.width / 2
        savedQuizzesButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        viewDidLayoutSubviews()
    }
    
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
        let image = UIImage(named: "ab")
        PageExtraction().extract(image) {
            imageOpt in
            if let image = imageOpt {
                let scanned = ScannedPage(image: image)
                let barcode = scanned.barcode
                println("Barcode is index \(barcode.index) and page # \(barcode.pageNum)")
                self.infoController.addPage(scanned)
            } else {
                println("Scan failed")
            }
        }
    }
    
    // MARK: quiz info controller
    var infoController = QuizInfoController()
    
    func statusChanged() {
        updateScanConstantly()
        darknessViewAlpha = scanner!.status == Scanner.Status.PossibleScan ? 0.5 : 0.0
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
            pageStatusLabel.text = NSString(format: NSLocalizedString("Page %i/%i", comment: ""), pages, total)
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
        
        let showEdu = !NSUserDefaults.standardUserDefaults().boolForKey(HasEverGradedQuizDefaultsKey).boolValue && !statusVisible
        edu.animateAlphaTo(showEdu ? 1 : 0, duration: 0.5)
        
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
    var darknessViewAlpha: CGFloat = 0.0 {
        willSet(val) {
            if val != darknessViewAlpha {
                self.darkness.animateAlphaTo(val, duration: 0.6)
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
    
    @IBOutlet var darkness: UIImageView!
    
    @IBAction func clearScannedPages() {
        infoController.clear()
    }
    
    @IBAction func acceptScannedQuiz() {
        if infoController.quiz != nil && infoController.status == QuizInfoController.Status.Done {
            let manualResponseTemplates = infoController.quiz!.getManuallyGradedResponseTemplates()
            if countElements(manualResponseTemplates.filter( { $0 != nil} )) > 0 {
                let navController = storyboard!.instantiateViewControllerWithIdentifier("ManualResponseNavController") as UINavigationController
                let manualResponseVC = navController.viewControllers.first! as ManualResponseViewController
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
    
    var justSavedQuizCount: Int = 0 {
        didSet {
            savedQuizzesButton.setTitle("\(justSavedQuizCount)", forState: UIControlState.Normal)
        }
    }
        
    func saveScannedQuiz() {
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
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: HasEverGradedQuizDefaultsKey)
        
        infoController.clear()
    }
    
    // MARK: Transitions
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowResults" {
            let resultsVC = (segue.destinationViewController as ResultsTableViewController)
            resultsVC.transitioningDelegate = resultsVC
            resultsVC.modalPresentationStyle = UIModalPresentationStyle.Custom
            justSavedQuizCount = 0
        }
    }
    
    // MARK: Flash
    var flash: Bool = false {
        didSet {
            flashButton.selected = flash
            if let camera = cameraView!.captureDevice {
                if camera.lockForConfiguration(nil) {
                    camera.torchMode = flash ? .On : .Off
                    camera.unlockForConfiguration()
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
    
}
