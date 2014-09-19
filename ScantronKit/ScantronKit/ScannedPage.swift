//
//  PageScanning.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/16/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

public func extractScannedPage(image: UIImage, callback: (ScannedPage? -> ())) {
    PageExtraction().extract(image) {
        (imageOpt: UIImage?) in
        if let image = imageOpt {
            callback(ScannedPage(image: image))
        } else {
            callback(nil)
        }
    }
}

public class ScannedPage {
    var image: UIImage
    var data: ImagePixelData
    public init(image: UIImage) {
        self.image = image
        self.data = image.pixelData()
        LOGImage(image, "extracted")
    }
    
    public var barcode: Barcode {
        get {
            let x: CGFloat = CGFloat(PROPORTIONAL_COMB_MARGIN) * image.size.width
            let y: CGFloat = CGFloat(1.0 - PROPORTIONAL_BARCODE_HEIGHT) * image.size.height
            let w: CGFloat = CGFloat(1.0-PROPORTIONAL_COMB_MARGIN*2.0) * image.size.width
            let h: CGFloat = CGFloat(PROPORTIONAL_BARCODE_HEIGHT) * image.size.height
            let barcodeFrame = CGRectIntegral(CGRectMake(x, y, w, h))
            let pixelsPerCol = barcodeFrame.width / CGFloat(BARCODE_HORIZONTAL_BITS)
            let pixelsPerRow = barcodeFrame.height / CGFloat(BARCODE_VERTICAL_BITS)
            let subImage = image.subImage(barcodeFrame)
            // UIImagePNGRepresentation(subImage).writeToFile("/Users/nateparrott/Desktop/op.png", atomically: true)
            let brightnessAtIndex = {
                (i: Int) -> Float in
                let col = i % BARCODE_HORIZONTAL_BITS
                let row = i / BARCODE_HORIZONTAL_BITS
                let rect = CGRectMake(barcodeFrame.origin.x + CGFloat(col) * pixelsPerCol, barcodeFrame.origin.y + CGFloat(row) * pixelsPerRow, pixelsPerCol, pixelsPerRow)
                let smaller = CGRectInset(rect, rect.size.width * 0.15, rect.size.height*0.15)
                return Float(self.data.averageBrightnessInRect(smaller))
            }
            let off = brightnessAtIndex(0)
            let on = brightnessAtIndex(1)
            let cutoff = (off + on) / 2.0
            let pixelValue = {
                (i: Int) -> Int in
                return (brightnessAtIndex(i) < cutoff) ? 1 : 0
            }
            let intFromBarcodeRange = {
                (start: Int, length: Int) -> Int in
                var val: Int = 0
                for i in start..<(start+length) {
                    let placeVal: Int = Int(pow(2.0, Double(length - 1 - (i-start))))
                    let x: Int = Int(pixelValue(i)) * placeVal
                    val += x
                }
                return val
            }
            let bitsForIndex = (BARCODE_HORIZONTAL_BITS * BARCODE_VERTICAL_BITS) - 2 - BARCODE_BITS_FOR_PAGE_NUM
            return Barcode(pageNum: intFromBarcodeRange(2, BARCODE_BITS_FOR_PAGE_NUM), index: intFromBarcodeRange(2 + BARCODE_BITS_FOR_PAGE_NUM, bitsForIndex))
        }
    }
}

let BARCODE_HORIZONTAL_BITS = 14
let BARCODE_VERTICAL_BITS = 2
let BARCODE_BITS_FOR_PAGE_NUM = 4
let PROPORTIONAL_COMB_MARGIN = 0.17
let PROPORTIONAL_BARCODE_HEIGHT = 0.06

public struct Barcode {
    public var pageNum: Int
    public var index: Int
}
