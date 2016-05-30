//
//  Tracking.swift
//  ScantronKit
//
//  Created by Nate Parrott on 8/3/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

struct TrackingPattern {
    var points: [CGPoint] // 6 points, left-to-right, top-to-bottom
}

@objc class Tracking: NSObject {
    func findTrackingPattern(image: UIImage, callback: (TrackingPattern?) -> ()) {
        ContourExtractor().extractContoursFromImage(image) {
            (contourArray: [AnyObject]?) in
            let contours = contourArray as! [Contour]
            if DEBUGMODE() {
                for c in contours {
                    print("Contour: \(c.pattern)")
                }
            }
            var pois: [String: [String: CGPoint]] = Dictionary()
            for desc in self.trackingPatterns {
                if let poiDict = self.POIsForTrackingContour(desc, contours: contours) {
                    pois[desc.name] = poiDict
                } else {
                    LOG("Missing tracking pattern \(desc.name)")
                }
            }
            let pointsOpt: [CGPoint?] = [
                pois["topLeft"]?["topLeft"],
                pois["topRight"]?["topRight"],
                pois["bottomLeft"]?["topLeft"],
                pois["bottomRight"]?["topRight"],
                pois["bottomLeft"]?["bottomLeft"],
                pois["bottomRight"]?["bottomRight"]
            ]
            let points = pointsOpt.filter({$0 != nil}).map({$0!})
            if points.count == 6 {
                callback(TrackingPattern(points: points))
            } else {
                callback(nil)
            }
        }
    }
    private func POIsForTrackingContour(desc: TrackingPatternDesc, contours: [Contour]) -> [String: CGPoint]? {
        let matches = contours.filter({desc.patternMatchesWithShift($0.pattern) != nil})
        if matches.count == 0 {
            return nil
        } else {
            let bestContour = matches.sort({$0.score() > $1.score()})[0]
            let shift = desc.patternMatchesWithShift(bestContour.pattern)!
            var keypoints: [String: CGPoint] = Dictionary()
            for (i, keypointName) in desc.pointIndexToPOIMap {
                keypoints[keypointName] = (bestContour.points[(i + shift) % bestContour.points.count] as! NSValue).CGPointValue()
            }
            return keypoints
        }
    }
    @objc func testTracking(imageLarge: UIImage, callback: (UIImage?) -> ()) {
        let image = resizeImage(imageLarge)
        findTrackingPattern(image) {
            (pattern: TrackingPattern?) in
            UIGraphicsBeginImageContext(image.size)
            image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
            UIColor.greenColor().setFill()
            if let pat = pattern {
                for point in pat.points {
                    let size: CGFloat = 10
                    UIBezierPath(ovalInRect: CGRectMake(point.x-size/2, point.y-size/2, size, size)).fill()
                }
            }
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            callback(result)
        }
    }
    @objc func annotateContours(imageLarge: UIImage, callback: (UIImage) -> ()) {
        let image = resizeImage(imageLarge)
        ContourExtractor().extractContoursFromImage(image) {
            (contourArray: [AnyObject]!) in
            let contours = contourArray as! [Contour]
            let toShow = contours.sort({$0.score() > $1.score()})[0..<min(8, contours.count)]
            UIGraphicsBeginImageContext(imageLarge.size)
            imageLarge.drawInRect(CGRectMake(0, 0, imageLarge.size.width, imageLarge.size.height))
            let scale = imageLarge.size.width / image.size.width
            let font = UIFont.boldSystemFontOfSize(7)
            let attributes: [String: AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.redColor()]
            for contour in toShow {
                let labelAt = (contour.points[0] as! NSValue).CGPointValue() - CGPointMake(0, -10) * scale
                (contour.pattern as NSString).drawAtPoint(labelAt, withAttributes: attributes)
                var i = 0
                for pointVal in contour.points {
                    let point = (pointVal as! NSValue).CGPointValue() * scale
                    ("\(i)" as NSString).drawAtPoint(point, withAttributes: attributes)
                    i++
                }
            }
            let annotated = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            callback(annotated)
        }
    }
    @objc let maxImageDimension: CGFloat = 500
    private let thresholdRadiusToImageSizeRatio: CGFloat = 0.2
    @objc func thresholdRadius() -> Int {
        return Int(roundf(Float(maxImageDimension * thresholdRadiusToImageSizeRatio) / 2)) * 2 + 1
    }
    @objc func resizeImage(image: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(CGSizeMake(maxImageDimension, maxImageDimension))
        image.drawInRect(CGRectMake(0, 0, maxImageDimension, maxImageDimension))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized
    }
    class TrackingPatternDesc {
        init(name: String, pattern: String, pointIndexToPOIMap: [Int: String]) {
            self.name = name
            self.pattern = pattern
            self.pointIndexToPOIMap = pointIndexToPOIMap
            self.pHash = pattern.rotationInsensitiveHash()
            self.pLen = pattern.utf16.count
        }
        var name: String
        var pattern: String
        var pointIndexToPOIMap: [Int: String]
        private var pHash: UInt
        private var pLen: Int
        func patternMatchesWithShift(string: String) -> Int? {
            if pHash == string.rotationInsensitiveHash() && pLen == string.utf16.count {
                for i in 0..<pLen {
                    if pattern == string.rotate(i) { return i }
                }
                return nil
            } else {
                return nil
            }
        }
    }
    private let trackingPatterns = [
        TrackingPatternDesc(name: "topLeft", pattern: "RLLRRLRRRLLRRR", pointIndexToPOIMap: [12: "topLeft", 7: "bottomLeft"]),
        TrackingPatternDesc(name: "topRight", pattern: "RRLLRRRLRRLLRR", pointIndexToPOIMap: [0: "topRight", 5: "bottomRight"]),
        TrackingPatternDesc(name: "bottomLeft", pattern: "LRRLRRRLLRRR", pointIndexToPOIMap: [10: "topLeft", 5: "bottomLeft"]),
        TrackingPatternDesc(name: "bottomRight", pattern: "RRRLRRLLRRLR", pointIndexToPOIMap: [0: "topRight", 1: "bottomRight"])
    ]
    @objc let contourMinEdgeCount = 11
}

public extension String {
    public func rotate(n: Int) -> String {
        return self[startIndex.advancedBy(n)..<endIndex] + self[startIndex..<startIndex.advancedBy(n)]
    }
    public func rotationInsensitiveHash() -> UInt {
        var h: UInt = 0
        let s: NSString = self
        let len = s.length
        for i in 0..<len {
            let c: unichar = s.characterAtIndex(i)
            h = h &+ UInt(c)
        }
        return h
    }
}

public extension Contour {
    public func score() -> Double {
        return self.area / (0.1 + self.irregularity)
    }
}
