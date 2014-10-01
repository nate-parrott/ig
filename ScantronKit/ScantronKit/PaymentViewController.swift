//
//  PaymentViewController.swift
//  ScantronKit
//
//  Created by Nate Parrott on 10/1/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateButtons()
    }
    
    @IBOutlet var loadingView: UIView!
    
    @IBOutlet var status: UILabel!
    @IBOutlet var paragraph: UILabel!
    
    @IBOutlet var backToAppButton: UIButton!
    
    @IBAction func subscribeForOneMonth() {
        addSubscriptionTime(60 * 60 * 24 * 31)
    }
    @IBAction func subscribeForOneYear() {
        addSubscriptionTime(60 * 60 * 24 * 365)
    }
    func addSubscriptionTime(time: NSTimeInterval) {
        SharedAPI().subscriptionEndDate = max(SharedAPI().subscriptionEndDate, NSDate().timeIntervalSince1970)
        SharedAPI().subscriptionEndDate += time
        SharedAPI().updateSubscriptionEndDate()
        updateButtons()
    }
    @IBAction func backToApp() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func updateButtons() {
        backToAppButton.backgroundColor = SharedAPI().canScan() ? view.tintColor : UIColor.grayColor()
        backToAppButton.enabled = SharedAPI().canScan()
    }
}
