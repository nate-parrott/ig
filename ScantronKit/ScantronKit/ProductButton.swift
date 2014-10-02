//
//  ProductButton.swift
//  ScantronKit
//
//  Created by Nate Parrott on 10/1/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

/*
ProductButton handles all aspects of fetching the price, initiating the transaction,
and indicating status.
It does *not* remove the transaction from the queue on success —
this is the job of the global PostTransactionOperationPool
*/

class ProductButton: UIButton, SKPaymentTransactionObserver {
    @IBInspectable var productIdentifier: String!
    @IBInspectable var titleTemplate: String! // {{PRICE}} will be replaced with the price
    @IBInspectable var titleWithoutPrice: String!
    @IBOutlet weak var viewController: UIViewController? // for presenting VC's
    
    // MARK: Setup
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(newWindow)
        if newWindow != nil {
            if !setupYet {
                setupYet = true
                setup()
            }
            reloadProduct()
        }
    }
    
    var setupYet = false
    func setup() {
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUIAfterDelay", name: PostTransactionOperationQueueStatusChangedNotification, object: nil)
        addTarget(self, action: "buy", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    deinit {
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Product loading
    func reloadProduct() {
        println("Identifier: \(productIdentifier)")
        CargoBay.sharedManager().productsWithIdentifiers(NSSet(array: [productIdentifier]), success: { (products, invalid) -> Void in
            if let p = products.first as? SKProduct {
                self.product = p
            } else {
                self.productLoadError = NSError()
            }
        }) { (error) -> Void in
            println("ERROR: \(error)")
            self.productLoadError = error
        }
        updateUI()
    }
    var product: SKProduct? {
        didSet {
            updateUI()
        }
    }
    var productLoadError: NSError? {
        didSet {
            updateUI()
        }
    }
    @IBAction func buy() {
        let transaction = SKPayment(product: product!)
        SKPaymentQueue.defaultQueue().addPayment(transaction)
    }
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        updateUI()
    }
    // MARK: UI
    func updateUI() {
        var enabled = false
        var title = ""
        if let transaction = enqueuedTransaction() {
            switch transaction.transactionState {
            case .Deferred: title = "Waiting for action..."
            case .Purchasing: title = "Purchasing..."
            case .Purchased: title = "Processing..."
            case .Failed: handleTransactionFailure()
            case .Restored: 0
            }
        } else {
            if let p = self.product {
                enabled = true
                title = titleTemplate!.stringByReplacingOccurrencesOfString("{{PRICE}}", withString: p.localizedPrice)
            } else {
                title = titleWithoutPrice
            }
        }
        self.enabled = enabled
        self.setTitle(title, forState: UIControlState.Normal)
    }
    func updateUIAfterDelay() {
        delay(0.1) {
            self.updateUI()
        }
    }
    func handleTransactionFailure() {
        if let t = enqueuedTransaction() {
            let alertController = UIAlertController(title: "Your purchase didn't go through.", message: "You haven't been charged, and you can try again if you want.", preferredStyle: UIAlertControllerStyle.Alert)
            println("ERROR: \(t.error)")
            alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: nil))
            viewController!.presentViewController(alertController, animated: true, completion: nil)
            SKPaymentQueue.defaultQueue().finishTransaction(t)
        }
        delay(0.1) {
            self.updateUI()
        }
    }
    
    // MARK: Helpers
    
    func enqueuedTransaction() -> SKPaymentTransaction? {
        for transaction in SKPaymentQueue.defaultQueue().transactions as [SKPaymentTransaction] {
            if transaction.payment.productIdentifier == productIdentifier {
                return transaction
            }
        }
        return nil
    }
}

class PostTransactionOperationPool: NSObject, SKPaymentTransactionObserver {
    override init () {
        super.init()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        processCompletedTransactions()
    }
    
    func processCompletedTransactions() {
        for t in SKPaymentQueue.defaultQueue().transactions as [SKPaymentTransaction] {
            if t.transactionState == .Purchased {
                if !workingOnTransactionsWithIdentifiers.contains(t.transactionIdentifier) {
                    workOnTransaction(t)
                }
            }
        }
    }
    
    let workingOnTransactionsWithIdentifiers = Set<String>()
    func workOnTransaction(t: SKPaymentTransaction) {
        workingOnTransactionsWithIdentifiers.add(t.transactionIdentifier)
        
        var secondsToAdd: NSTimeInterval = 0
        switch t.payment.productIdentifier {
            case "31": secondsToAdd = 31 * 24 * 60 * 60
            case "365": secondsToAdd = 365 * 24 * 60 * 60
            default: 0
        }
        
        SharedAPI().updateUserData(["add_subscription_seconds": "\(secondsToAdd)"]) {
            (success) in
            if success {
                self.workingOnTransactionsWithIdentifiers.remove(t.transactionIdentifier)
                SKPaymentQueue.defaultQueue().finishTransaction(t)
                NSNotificationCenter.defaultCenter().postNotificationName(PostTransactionOperationQueueStatusChangedNotification, object: self)
            }
        }
    }
}

let PostTransactionOperationQueueStatusChangedNotification = "PostTransactionOperationQueueStatusChangedNotification"

var _SharedPostTransactionOperationPool: PostTransactionOperationPool? = nil
func SharedPostTransactionOperationPool() -> PostTransactionOperationPool {
    if let shared = _SharedPostTransactionOperationPool {
        return shared
    } else {
        _SharedPostTransactionOperationPool = PostTransactionOperationPool()
        return _SharedPostTransactionOperationPool!
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