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
}
