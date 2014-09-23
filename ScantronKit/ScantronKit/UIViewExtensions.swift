//
//  UIViewExtensions.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/22/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

extension UIView {
    func animateAlphaTo(alpha: CGFloat, duration: NSTimeInterval) {
        var currentAlpha = self.alpha
        if let presentationLayer = self.layer.presentationLayer()? as? CALayer {
            currentAlpha = CGFloat(presentationLayer.opacity)
        }
        self.alpha = currentAlpha
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            self.alpha = alpha
        }) { (_) -> Void in
            
        }
    }
    
    var left: CGFloat {
        get {
            return frame.origin.x
        }
        set(val) {
            frame = CGRectMake(val, frame.origin.y, frame.size.width, frame.size.height)
        }
    }
    var top: CGFloat {
        get {
            return frame.origin.y
        }
        set(val) {
            frame = CGRectMake(frame.origin.x, val, frame.size.width, frame.size.height)
        }
    }
    var right: CGFloat {
        get {
            return frame.origin.x + frame.size.width
        }
        set(val) {
            frame = CGRectMake(frame.origin.x, frame.origin.y, val - frame.origin.x, frame.size.height)
        }
    }
    var bottom: CGFloat {
        get {
            return frame.origin.y + frame.size.height
        }
        set(val) {
            frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, val - frame.origin.y)
        }
    }
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set(val) {
            frame = CGRectMake(frame.origin.x, frame.origin.y, val, frame.size.height)
        }
    }
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set(val) {
            frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height)
        }
    }
    var size: CGSize {
        get {
            return frame.size
        }
        set(val) {
            frame = CGRectMake(frame.origin.x, frame.origin.y, val.width, val.height)
        }
    }
}
