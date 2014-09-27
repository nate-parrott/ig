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

class API: NSObject, NSURLSessionDelegate {
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
    
    private func makeURLRequest(endpoint: String, var args: [String: String]) -> NSMutableURLRequest {
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
        let request = NSMutableURLRequest(URL: url)
        return request
    }
    
    func call(endpoint: String, args: [String: String], callback: NSData? -> ()) -> NSURLSessionTask {
        let request = makeURLRequest(endpoint, args: args)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            callback(data)
        })
        task.resume()
        return task
    }
    
    func fetchQuizWithIndex(index: Int, callback: Quiz? -> ()) {
        if let quiz = findLocalQuizWithIndex(index) {
            callback(quiz)
        } else {
            queriedQuizIds.add(index)
            call("/\(index)/details", args: [String: String]()) {
                (dataOpt: NSData?) in
                if let data = dataOpt {
                    if let response = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? [String: AnyObject] {
                        let quiz = Quiz(entity: NSEntityDescription.entityForName("Quiz", inManagedObjectContext: SharedCoreDataManager().managedObjectContext!)!, insertIntoManagedObjectContext: SharedCoreDataManager().managedObjectContext!)
                        quiz.title = response["title"]! as String
                        quiz.added = NSDate()
                        quiz.json = response["json"]!
                        quiz.index = index
                        callback(quiz)
                        return
                    }
                } else {
                    self.queriedQuizIds.remove(index)
                }
                callback(nil)
            }
        }
    }
    
    func uploadQuizInstances() {
        let maxQuizzesToUpload = 20
        
        let query = NSFetchRequest(entityName: "QuizInstance")
        query.predicate = NSPredicate(format: "uploadedInBatch = NULL")
        let notYetUploaded = SharedCoreDataManager().managedObjectContext!.executeFetchRequest(query, error: nil)! as [QuizInstance]
        if countElements(notYetUploaded) > 0 {
            let rangeEnd = min(countElements(notYetUploaded), maxQuizzesToUpload)
            let uploading = Array(notYetUploaded[0..<rangeEnd])
            
            let batchName = "date:\(NSDate.timeIntervalSinceReferenceDate())"
            for item in uploading {
                item.uploadedInBatch = batchName
            }
            
            let postJson: [String: AnyObject] = ["quizInstances": uploading.map({ $0.serialize() })]
            let postData = (postJson as NSDictionary).messagePack()
            let urlReq = makeURLRequest("/upload_quiz_instances", args: [String: String]())
            urlReq.HTTPMethod = "POST"
            urlReq.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            SharedBackgroundUploader().startUpload(urlReq, data: postData, type: "QuizUpload", info: ["BatchName": batchName])
        }
    }
    
    func findLocalQuizWithIndex(index: Int) -> Quiz? {
        let query = NSFetchRequest(entityName: "Quiz")
        query.predicate = NSPredicate(format: "index = %@", NSNumber(integer: index))
        return SharedCoreDataManager().managedObjectContext!.executeFetchRequest(query, error: nil)?.first as? Quiz
    }
    var queriedQuizIds = Set<Int>()
    
    
    
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


func setupQuizUploadHandler(uploader: BackgroundUploader) {
    uploader.handlersForTypes["QuizUpload"] = {
        (task: NSURLSessionTask, error: NSError?, userInfo: [String: AnyObject]) in
        AsyncOnMainQueue() {
            let batchName = userInfo.get("BatchName")! as String
            let query = NSFetchRequest(entityName: "QuizInstance")
            query.predicate = NSPredicate(format: "uploadedInBatch = %@", batchName)
            let itemsInBatch = SharedCoreDataManager().managedObjectContext!.executeFetchRequest(query, error: nil)! as [QuizInstance]
            if let actualError = error {
                for item in itemsInBatch {
                    item.uploadedInBatch = nil
                }
            } else {
                for item in itemsInBatch {
                    item.uploaded = true
                }
            }
        }
    }
}
