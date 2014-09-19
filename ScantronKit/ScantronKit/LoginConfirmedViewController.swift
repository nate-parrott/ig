//
//  LoginConfirmedViewController.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/15/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class LoginConfirmedViewController: UIViewController {
    var authUrl: NSURL?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loginState = LoginState.None
        if let url = authUrl {
            if let token = url.queryValueForKey("token") {
                let task = SharedAPI().loginWithToken(token) {
                    if let email = SharedAPI().userEmail {
                        self.loginState = LoginState.Suceeded
                    } else {
                        self.loginState = LoginState.Failed(error: nil)
                    }
                }
                loginState = LoginState.Loading(task: task)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        switch loginState {
        case LoginState.Loading(task: let taskOpt):
            if let task = taskOpt {
                task.cancel()
            }
        default: 0
        }
        loginState = LoginState.None
    }
    
    // MARK: UI
    
    @IBAction func done() {
        navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet var loading: UIActivityIndicatorView?
    @IBOutlet var successView: UIView?
    @IBOutlet var failureView: UIView?
    @IBOutlet var welcomeLabel: UILabel?
    
    enum LoginState {
        case Loading(task: NSURLSessionTask?)
        case Failed(error: NSError?)
        case Suceeded
        case None
    }
    var loginState: LoginState = LoginState.None {
        didSet {
            loading!.stopAnimating()
            successView!.hidden = true
            failureView!.hidden = true
            switch loginState {
            case .Loading(task: _): loading!.startAnimating()
            case .Suceeded:
                successView!.hidden = false
                welcomeLabel!.text = NSString(format: NSLocalizedString("Hi there, %@!", comment: "Welcome message: Hi there, [email]!"), SharedAPI().userEmail!)
            case .Failed(error: _): failureView!.hidden = false
            default: 0
            }
        }
    }
}
