//
//  PageExtraction.swift
//  ScantronKit
//
//  Created by Nate Parrott on 8/9/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

@objc class PageExtraction: NSObject {
    @objc func extract(image: UIImage, callback: UIImage? -> ()) {
        let scaledImage = Tracking().resizeImage(image)
        var square: UIImage? = nil
        
        let waitForSquare = dispatch_semaphore_create(0)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            square = image.makeSquare()
            dispatch_semaphore_signal(waitForSquare)
        })
        
        Tracking().findTrackingPattern(scaledImage) {
            patternOpt in
            LOG(patternOpt == nil ? "No tracking pattern found" : "Tracking pattern found")
            
            if let scaledPattern = patternOpt {
                
                if DEBUGMODE() {
                    UIGraphicsBeginImageContext(scaledImage.size)
                    image.drawInRect(CGRectMake(0, 0, scaledImage.size.width, scaledImage.size.height))
                    UIColor.greenColor().setFill()
                    for point in scaledPattern.points {
                        let size: CGFloat = 10
                        UIBezierPath(ovalInRect: CGRectMake(point.x-size/2, point.y-size/2, size, size)).fill()
                    }
                    let result = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    LOGImage(result, "trackingPoints")
                }
                
                dispatch_semaphore_wait(waitForSquare, DISPATCH_TIME_FOREVER)
                
                let scale = CGPointMake(scaledImage.size.width / square!.size.width, scaledImage.size.height / square!.size.height)
                let unscaledPattern = TrackingPattern(points: scaledPattern.points.map({$0 / scale}))
                let pageOpt = Unprojection().unproject(square!, tracking: unscaledPattern)
                callback(pageOpt)
            } else {
                callback(nil)
            }
        }
    }
}
