//
//  AppDelegate.swift
//  ScantronKit
//
//  Created by Nate Parrott on 7/30/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit
import CoreData
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        Crashlytics.startWithAPIKey("c00a274f2c47ad5ee89b17ccb2fdb86e8d1fece8")
        
        _ = Mixpanel.sharedInstanceWithToken("d49cfebb673bdf3d240758901998dc9d")
        
        SharedReachability = KSReachability(toHost: "instagradeapp.com")
        SharedReachability.notificationName = kDefaultNetworkReachabilityChangedNotification
        SharedReachability.onInitializationComplete = {
            (_) in
            NSNotificationCenter.defaultCenter().postNotificationName(kDefaultNetworkReachabilityChangedNotification, object: SharedReachability)
        }
        
        SharedAPI() // cause it to be instantiated and listening to background session notifications
        
        refreshNetworkThings()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.updateRootUI), name: APILoginStatusChangedNotification, object: nil)
        
        SetupAppearanceWithWindow(self.window)
        
        updateRootUI()
        
        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.makeKeyAndVisible()
        
        return true
    }
    
    func updateRootUI() {
         // window!.rootViewController = UIStoryboard(name: "Scratch", bundle: nil).instantiateInitialViewController() as? UIViewController
         // return
        
        if SharedAPI().userEmail != nil {
            self.window!.rootViewController = UIStoryboard(name: "App", bundle: nil).instantiateInitialViewController()
        } else {
            self.window!.rootViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // clean up old quizzes:
        SharedCoreDataManager().save() // for some reason unsaved changes break .fetchOffset, so save first
        let req = NSFetchRequest(entityName: "QuizInstance")
        req.predicate = NSPredicate(format: "uploaded = YES")
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        req.fetchOffset = 100 // keep last 100
        req.includesPropertyValues = false // we're gonna delete em, so
        for obj in try! SharedCoreDataManager().managedObjectContext!.executeFetchRequest(req) as! [QuizInstance] {
            SharedCoreDataManager().managedObjectContext!.deleteObject(obj)
        }
        
        SharedCoreDataManager().save()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        refreshNetworkThings()
        Mixpanel.sharedInstance().track("Foreground")
    }
    
    func refreshNetworkThings() {
        if SharedAPI().userToken != nil {
            SharedAPI().refreshData() {
                (succesOpt) in
            }
        }
        SharedAPI().uploadQuizInstances()
        SharedPostTransactionOperationPool().processCompletedTransactions()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        SharedCoreDataManager().save()
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        var dict: [NSObject: AnyObject] = [ApplicationDidOpenURLNotificationURLKey: url]
        if let src = sourceApplication {
            dict[ApplicationDidOpenURLNotificationSourceAppKey] = src
        }
        if let ann: AnyObject = annotation {
            dict[ApplicationDidOpenURLNotificationAnnotationKey] = ann
        }
        NSNotificationCenter.defaultCenter().postNotificationName(ApplicationDidOpenURLNotification, object: nil, userInfo: dict)
        return true
    }
    
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        if identifier == BackgroundUploaderSessionIdentifier {
            SharedBackgroundUploader().backgroundCompletionHandler = completionHandler
        }
    }
}

let ApplicationDidOpenURLNotification = "ApplicationDidOpenURLNotification"
let ApplicationDidOpenURLNotificationURLKey = "URL"
let ApplicationDidOpenURLNotificationSourceAppKey = "SourceApp"
let ApplicationDidOpenURLNotificationAnnotationKey = "Annotation"

var SharedReachability: KSReachability! = nil

