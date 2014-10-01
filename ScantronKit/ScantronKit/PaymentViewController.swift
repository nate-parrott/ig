//
//  PaymentViewController.swift
//  ScantronKit
//
//  Created by Nate Parrott on 10/1/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController, SKPaymentTransactionObserver {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    deinit {
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        SharedAPI().refreshData() {
            (success: Bool) in
            self.updateUI()
        }
        loadProducts()
        
        processLeftoverSuccessfulTransactions()
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
    
    @IBAction func subscribeForOneMonth() {
        purchaseProduct(oneMonthSubscription!)
    }
    @IBAction func subscribeForOneYear() {
        purchaseProduct(oneYearSubscription!)
    }
    func addSubscriptionTime(time: NSTimeInterval, callback: ((success: Bool) -> ())) {
        loading = true
        SharedAPI().updateUserData(["add_subscription_seconds": "\(time)"], callback: callback)
    }
    func showError(text: String = "Sorry, an error occurred.") {
        let alertController = UIAlertController(title: nil, message: text, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func backToApp() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func updateUI() {
        backToAppButton.backgroundColor = SharedAPI().canScan() ? view.tintColor : UIColor.grayColor()
        backToAppButton.enabled = SharedAPI().canScan()
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
    
    // MARK: Loading products
    var oneYearSubscription: SKProduct? {
        didSet {
            if let sub = oneYearSubscription {
                oneYearSubscriptionButton.setTitle("Add one-year subscription for \(sub.localizedPrice)", forState: UIControlState.Normal)
                oneYearSubscriptionButton.enabled = true
            }
        }
    }
    var oneMonthSubscription: SKProduct? {
        didSet {
            if let sub = oneMonthSubscription {
                oneMonthSubscriptionButton.setTitle("Add one-month subscription for \(sub.localizedPrice)", forState: UIControlState.Normal)
                oneMonthSubscriptionButton.enabled = true
            }
        }
    }
    @IBOutlet var oneYearSubscriptionButton: UIButton!
    @IBOutlet var oneMonthSubscriptionButton: UIButton!
    @IBOutlet var subscriptionPricesLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet var subscriptionPricesLoadingFailureButton: UIButton!
    @IBAction func loadProducts() {
        subscriptionPricesLoadingIndicator.startAnimating()
        self.subscriptionPricesLoadingFailureButton.hidden = true
        let identifiersSet = NSSet(array: ["31", "365"])
        /*    - (void)productsWithIdentifiers:(NSSet *)identifiers
        success:(void (^)(NSArray *products, NSArray *invalidIdentifiers))success
        failure:(void (^)(NSError *error))failure;*/
        CargoBay.sharedManager().productsWithIdentifiers(identifiersSet, success: { (let products, let invalidIds) -> Void in
            self.subscriptionPricesLoadingIndicator.stopAnimating()
            for p in (products as [SKProduct]) {
                switch p.productIdentifier {
                    case "31": self.oneMonthSubscription = p
                    case "365": self.oneYearSubscription = p
                    default: 0
                }
            }
        }) { (let error) -> Void in
            self.subscriptionPricesLoadingIndicator.stopAnimating()
            self.subscriptionPricesLoadingFailureButton.hidden = false
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        var showLoading = false
        for t in (transactions as [SKPaymentTransaction]) {
            switch t.transactionState {
            case .Purchasing:
                showLoading = true
            case .Purchased:
                purchaseSucceeded(t)
            case .Deferred:
                0
            case .Failed:
                purchaseFailed(t)
            case .Restored:
                0
            }
        }
        loading = showLoading
    }
    
    func purchaseSucceeded(transaction: SKPaymentTransaction) {
        var timeToAdd: NSTimeInterval = 0
        switch transaction.payment.productIdentifier {
            case "31": timeToAdd = 31 * 24 * 60 * 60
            case "365": timeToAdd = 365 * 24 * 60 * 60
            default: 0
        }
        loading = true
        if timeToAdd > 0 {
            addSubscriptionTime(timeToAdd) {
                (success) in
                if success {
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                    self.updateUI()
                } else {
                    
                }
                self.loading = false
            }
        } else {
            SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        }
    }
    
    func purchaseFailed(transaction: SKPaymentTransaction) {
        showError(text: "Whoops — your purchase didn't go through. You haven't been charged.")
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    func purchaseProduct(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
        loading = true
    }
    
    func processLeftoverSuccessfulTransactions() {
        // TODO: don't process a payment again while server post is going through
        for transaction in (SKPaymentQueue.defaultQueue().transactions as [SKPaymentTransaction]) {
            if transaction.transactionState == .Purchased {
                purchaseSucceeded(transaction)
            }
        }
    }
}

extension SKProduct {
    var localizedPrice: String {
        get {
            let formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
            formatter.locale = self.priceLocale
            return formatter.stringFromNumber(self.price)
        }
    }
}

