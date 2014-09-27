//
//  BackgroundUploader.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/26/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

let BackgroundUploaderSessionIdentifier = "com.nateparrott.InstaGrade-Scanner.BackgroundUploader"

class BackgroundUploader: NSObject, NSURLSessionTaskDelegate {
    override init() {
        super.init()
        let conf = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(BackgroundUploaderSessionIdentifier)
        conf.discretionary = false
        session = NSURLSession(configuration: conf, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        setupHandlers()
    }
    var session: NSURLSession!
    
    typealias CompletionHandler = (NSURLSessionTask, NSError?, [String: AnyObject]) -> ()
    
    var handlersForTypes = [String: CompletionHandler]()
    
    func setupHandlers() {
        setupQuizUploadHandler(self)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        let infoJson = NSUserDefaults.standardUserDefaults().valueForKey("com.nateparrott.BackgroundUploader.task-\(task.taskIdentifier)") as NSData
        let info: [String: AnyObject] = NSJSONSerialization.JSONObjectWithData(infoJson, options: nil, error: nil) as [String: AnyObject]
        NSUserDefaults.standardUserDefaults().removeObjectForKey("com.nateparrott.BackgroundUploader.task-\(task.taskIdentifier)")
        let type = info.getOrDefault("type", defaultVal: "") as String
        NSFileManager.defaultManager().removeItemAtURL(
            urlForUploadDataWithFilename(info.getOrDefault("filename", defaultVal: "") as String),
            error: nil)
        let handler = handlersForTypes.get(type)! as CompletionHandler
        handler(task, error, info.get("userInfo")! as [String: AnyObject])
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        if let c = backgroundCompletionHandler {
            backgroundCompletionHandler = nil
            c()
        }
    }
    
    var backgroundCompletionHandler: (() -> ())?
    
    private func urlForUploadDataWithFilename(filename: String) -> NSURL {
        let uploadsDir = (NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first! as NSURL).URLByAppendingPathComponent("BackgroundUploads")
        if !NSFileManager.defaultManager().fileExistsAtPath(uploadsDir.path!) {
            NSFileManager.defaultManager().createDirectoryAtURL(uploadsDir, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
        let fileUrl = uploadsDir.URLByAppendingPathComponent(filename)
        return fileUrl
    }
    
    func startUpload(request: NSURLRequest, data: NSData, type: String, info: [String: AnyObject]) {
        let filename = "upload-\(NSDate.timeIntervalSinceReferenceDate())"
        data.writeToURL(urlForUploadDataWithFilename(filename), atomically: true)
        
        let task = session.uploadTaskWithRequest(request, fromFile: urlForUploadDataWithFilename(filename))
        let json: [String: AnyObject] = ["type": type, "userInfo": info, "filename": filename]
        NSUserDefaults.standardUserDefaults().setObject(NSJSONSerialization.dataWithJSONObject(json, options: nil, error: nil), forKey: "com.nateparrott.BackgroundUploader.task-\(task.taskIdentifier)")
        task.resume()
    }
    
}

private var _SharedBackgroundUploader: BackgroundUploader? = nil
func SharedBackgroundUploader() -> BackgroundUploader {
    if let bg = _SharedBackgroundUploader {
        return bg
    } else {
        _SharedBackgroundUploader = BackgroundUploader()
        return _SharedBackgroundUploader!
    }
}
