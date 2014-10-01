//
//  LoginViewController.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/17/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIWebViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }
    
    @IBAction func reload() {
        let (host, port) = APIHost()
        let url = "http://\(host):\(port)/get_token"
        self.webView!.loadRequest(NSURLRequest(URL: NSURL(string: url)))
    }
    
    @IBOutlet var webView: UIWebView?
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.URL.scheme! == "instagrade-login-token" {
            let token = request.URL.queryValueForKey("token")!
            NSUserDefaults.standardUserDefaults().setObject(token, forKey: "Token")
            performSegueWithIdentifier("ShowUserDataLoaderViewController", sender: nil)
            return false
        }
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        loader.animateAlphaTo(1, duration: 0.5)
        error.hidden = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        loader.animateAlphaTo(0, duration: 0.5)
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        self.error.hidden = false
    }
    
    @IBOutlet var loader: UIActivityIndicatorView!
    
    @IBOutlet var error: UIView!
}

class UserDataLoaderViewController: UIViewController {
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        SharedAPI().refreshData() {
            (success) in
            if success {
                NSNotificationCenter.defaultCenter().postNotificationName(APILoginStatusChangedNotification, object: nil)
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("Token")
                self.navigationController!.popViewControllerAnimated(true)
            }
        }
    }
}
