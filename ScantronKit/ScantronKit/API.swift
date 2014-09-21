//
//  API.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/15/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

func APIHost() -> (String, Int) {
    let host = IS_SIMULATOR() ? "localhost" : "instagradeformbuilder.appspot.com"
    let port = IS_SIMULATOR() ? 13080 : 80
    return (host, port)
}

class API: NSObject {
    var userEmail: String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("Email") as? String
        }
    }
    var userToken: String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("Token") as? String
        }
    }
    func gotToken(token: String, email: String) {
        NSUserDefaults.standardUserDefaults().setObject(token, forKey: "Token")
        NSUserDefaults.standardUserDefaults().setObject(email, forKey: "Email")
        NSNotificationCenter.defaultCenter().postNotificationName(APILoginStatusChangedNotification, object: nil)
    }
    func logOut() {
        // TODO: clear core data
        for key in ["Token", "Email"] {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
        }
        NSNotificationCenter.defaultCenter().postNotificationName("APILoginStatusChangedNotification", object: nil)
    }
    func call(endpoint: String, var args: [String: String], callback: NSData? -> ()) -> NSURLSessionTask {
        let urlComponents = NSURLComponents()
        
        let (host, port) = APIHost()
        urlComponents.host = host
        urlComponents.port = port
        
        if let token = userToken {
            args["token"] = token
        }
        urlComponents.queryItems = args.items().map({ NSURLQueryItem(name: $0.0, value: $0.1) })
        urlComponents.path = endpoint
        urlComponents.scheme = "http"
        let url = urlComponents.URL!
        println("URL: \(url)")
        let request = NSURLRequest(URL: url)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            callback(data)
        })
        task.resume()
        return task
    }
    func getQuizWithIndex(index: Int, callback: Quiz? -> ()) {
        let query = NSFetchRequest(entityName: "Quiz")
        query.predicate = NSPredicate(format: "index = %@", NSNumber(integer: index))
        if let quiz = SharedCoreDataManager().managedObjectContext!.executeFetchRequest(query, error: nil)?.first as? Quiz {
            callback(quiz)
        } else {
            call("/\(index)/details", args: [String: String]()) {
                (dataOpt: NSData?) in
                if let data = dataOpt {
                    if let response = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? [String: AnyObject] {
                        let quiz = Quiz(entity: NSEntityDescription.entityForName("Quiz", inManagedObjectContext: SharedCoreDataManager().managedObjectContext!)!, insertIntoManagedObjectContext: SharedCoreDataManager().managedObjectContext!)
                        quiz.title = response["title"]! as String
                        quiz.added = NSDate()
                        quiz.json = response["json"]!
                        callback(quiz)
                        return
                    }
                }
                callback(nil)
            }
        }
    }
}

var _sharedAPI: API? = nil
func SharedAPI() -> API {
    if let api = _sharedAPI {
        return api
    } else {
        _sharedAPI = API()
        return _sharedAPI!
    }
}

let APILoginStatusChangedNotification = "APILoginStatusChangedNotification"
