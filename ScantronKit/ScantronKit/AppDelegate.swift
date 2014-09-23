//
//  AppDelegate.swift
//  ScantronKit
//
//  Created by Nate Parrott on 7/30/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.makeKeyAndVisible()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateRootUI", name: APILoginStatusChangedNotification, object: nil)
        
        updateRootUI()
        return true
    }
    
    func updateRootUI() {
        //window!.rootViewController = UIStoryboard(name: "Scratch", bundle: nil).instantiateInitialViewController() as? UIViewController
        //return
        
        if SharedAPI().userEmail != nil {
            self.window!.rootViewController = UIStoryboard(name: "App", bundle: nil).instantiateInitialViewController() as? UIViewController
        } else {
            self.window!.rootViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() as? UIViewController
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String, annotation: AnyObject?) -> Bool {
        var dict: [NSObject: AnyObject] = [ApplicationDidOpenURLNotificationURLKey: url, ApplicationDidOpenURLNotificationSourceAppKey: sourceApplication]
        if let ann: AnyObject = annotation {
            dict[ApplicationDidOpenURLNotificationAnnotationKey] = ann
        }
        NSNotificationCenter.defaultCenter().postNotificationName(ApplicationDidOpenURLNotification, object: nil, userInfo: dict)
        return true
    }
}

let ApplicationDidOpenURLNotification = "ApplicationDidOpenURLNotification"
let ApplicationDidOpenURLNotificationURLKey = "URL"
let ApplicationDidOpenURLNotificationSourceAppKey = "SourceApp"
let ApplicationDidOpenURLNotificationAnnotationKey = "Annotation"

