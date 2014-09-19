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
        reload()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func reload() {
        let url = "http://\(APIHost):\(APIPort)/get_token"
        self.webView!.loadRequest(NSURLRequest(URL: NSURL(string: url)))
    }
    
    @IBOutlet var webView: UIWebView?
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.URL.scheme! == "instagrade-login-token" {
            let token = request.URL.queryValueForKey("token")!
            let email = request.URL.queryValueForKey("email")!
            SharedAPI().gotToken(token, email: email)
            return false
        }
        return true
    }
}
