//
//  Unprojection.swift
//  ScantronKit
//
//  Created by Nate Parrott on 8/9/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit
import QuartzCore

class Unprojection: NSObject {
    func unproject(image: UIImage, tracking: TrackingPattern) -> UIImage {
        let top = (topLeft: tracking.points[0], topRight: tracking.points[1], bottomLeft: tracking.points[2], bottomRight: tracking.points[3])
        let bottom = (topLeft: tracking.points[2], topRight: tracking.points[3], bottomLeft: tracking.points[4], bottomRight: tracking.points[5])
        
        let picture = GPUImagePicture(image: image)
        let concatter = ImageConcatenationFilter(fractionSplit: 0.4297)
        concatter.forceProcessingAtSize(image.size * 0.7)
        
        let quads = [top, bottom]
        for i in 0..<2 {
            let (topLeft, topRight, bottomLeft, bottomRight) = quads[i]
            let points = [topLeft, topRight, bottomRight, bottomLeft]
            let unitPoints = points.map({$0 / image.size})
            let transform3d = SKMath.reverseProjectionTransformationWithQuad(UnsafeMutablePointer(unitPoints))
            let transformer = GPUImageTransformFilter()
            transformer.anchorTopLeft = true
            transformer.transform3D = transform3d.flippedAndMirrored()
            transformer.forceProcessingAtSize(CGSizeMake(image.size.width, image.size.height/2)) // b/c each resulting unprojected image is ~half of the final image
            transformer.ignoreAspectRatio = true
            picture.addTarget(transformer)
            transformer.addTarget(concatter, atTextureLocation: 1-i) // for some reason they need to be swapped
        }
        concatter.useNextFrameForImageCapture()
        picture.processImage()
        return concatter.imageFromCurrentFramebufferWithOrientation(UIImageOrientation.Up)
    }
    private func unprojectQuad(image: UIImage, corners: (topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint)) -> UIImage {
        let (topLeft, topRight, bottomLeft, bottomRight) = corners
        let points = [topLeft, topRight, bottomRight, bottomLeft]
        let unitPoints = points.map({$0 / image.size})
        let transform3d = SKMath.reverseProjectionTransformationWithQuad(UnsafeMutablePointer(unitPoints))
        let transformer = GPUImageTransformFilter()
        transformer.anchorTopLeft = true
        transformer.transform3D = transform3d.flippedAndMirrored()
        transformer.forceProcessingAtSize(CGSizeMake(image.size.width, image.size.height/2)) // b/c each resulting unprojected image is ~half of the final image
        transformer.ignoreAspectRatio = true
        return transformer.imageByFilteringImage(image)
    }
    private func concatImages(images: [UIImage], scaleFactors: [CGFloat]) -> UIImage {
        var height: CGFloat = 0.0
        for (image, scaleFactor) in Zip2(images, scaleFactors) {
            height += image.size.height * scaleFactor
        }
        let width = images[0].size.width
        UIGraphicsBeginImageContext(CGSizeMake(width, height))
        var y: CGFloat = 0
        for (image, scaleFactor) in Zip2(images, scaleFactors) {
            image.drawInRect(CGRectMake(0, y, image.size.width, image.size.height * scaleFactor))
            y += image.size.height * scaleFactor
        }
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}

extension UIImage {
    func resize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        self.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized
    }
    func makeSquare() -> UIImage {
        let size = max(self.size.width, self.size.height)
        return self.resize(CGSizeMake(size, size))
    }
}

extension CATransform3D {
    func flippedAndMirrored() -> CATransform3D {
        let flipAndMirror = CATransform3DTranslate(CATransform3DScale(CATransform3DMakeTranslation(0.5, 0.5, 0), -1, -1, 1), -0.5, -0.5, 0)
        return CATransform3DConcat(self, flipAndMirror)
    }
}
