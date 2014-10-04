//
//  UIImage+SubImage.swift
//  Backgrounder
//
//  Created by Nate Parrott on 6/15/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

extension UIImage {
    func subImage(rect: CGRect) -> UIImage {        
        UIGraphicsBeginImageContext(rect.size)
        self.drawAtPoint(CGPointMake(-rect.origin.x, -rect.origin.y))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
