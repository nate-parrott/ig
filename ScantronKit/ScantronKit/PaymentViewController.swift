//
//  PaymentViewController.swift
//  ScantronKit
//
//  Created by Nate Parrott on 10/1/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI", name: PostTransactionOperationQueueStatusChangedNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        SharedAPI().refreshData() {
            (success: Bool) in
            self.updateUI()
        }
    }
    
    @IBOutlet var loadingView: UIView!
    
    var loading: Bool = false {
        didSet {
            loadingView.animateAlphaTo(loading ? 1 : 0, duration: 0.5)
            loadingView.userInteractionEnabled = !loading
        }
    }
    
    @IBOutlet var status: UILabel!
    @IBOutlet var paragraph: UILabel!
    
    @IBOutlet var backToAppButton: UIButton!
    
    func addSubscriptionTime(time: NSTimeInterval, callback: ((success: Bool) -> ())) {
        loading = true
        SharedAPI().updateUserData(["add_subscription_seconds": "\(time)"], callback: callback)
    }
    func showError(text: String = "Sorry, an error occurred.") {
        let alertController = UIAlertController(title: nil, message: text, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    var onDismiss: (() -> ())?
    @IBAction func backToApp() {
        if !SharedAPI().canScan() {
            // give 'em just one:
            SharedAPI().scansLeft = 1
        }
        if let cb = onDismiss {
            cb()
            onDismiss = nil
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateUI() {
        if SharedAPI().canScan() {
            backToAppButton.backgroundColor = view.tintColor
            backToAppButton.setTitle("Use InstaGrade", forState: UIControlState.Normal)
        } else {
            backToAppButton.backgroundColor = UIColor.grayColor()
            backToAppButton.setTitle("Just one more scan", forState: UIControlState.Normal)
        }
        let remainingSeconds = SharedAPI().subscriptionEndDate - NSDate().timeIntervalSince1970
        if remainingSeconds > 0 {
            let days = Int(round(remainingSeconds / (24 * 60 * 60)))
            status.text = "\(days) Days Left"
            paragraph.text = "in your subscription. Thanks for supporting InstaGrade!"
        } else {
            status.text = "\(SharedAPI().scansLeft) Scans Left"
            paragraph.text = "Running InstaGrade isn't free. After you've used 100 scans, we ask that you help support us by purchasing a subscription."
        }
    }
    
}


