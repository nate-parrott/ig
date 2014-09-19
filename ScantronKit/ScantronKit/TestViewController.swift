//
//  TestViewController.swift
//  ScantronKit
//
//  Created by Nate Parrott on 8/3/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction func takePhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    private var original: UIImage?
    private let iterations = 4
    private var startTime: NSTimeInterval = 0
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        let imageOpt = info[UIImagePickerControllerOriginalImage] as? UIImage
        dismissViewControllerAnimated(true, completion: {
            if let image = imageOpt {
                self.original = image
                self.startTime = NSDate.timeIntervalSinceReferenceDate()
                self.processImage(image, remainingIterations: self.iterations)
            }
        })
    }
    func processImage(image: UIImage, remainingIterations: Int) {
        Tracking().testTracking(image, {
            if $0 == nil || remainingIterations == 0 {
                self.imageView!.image = $0
                if remainingIterations == 0 {
                    let time = NSDate.timeIntervalSinceReferenceDate() - self.startTime
                    let averageSpeed = time / Double(self.iterations)
                    let alert = UIAlertController(title: "Success", message: "\(self.iterations) iterations at \(averageSpeed) seconds on average", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            } else {
                self.processImage(image, remainingIterations: remainingIterations-1)
            }
        })
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBOutlet var imageView: UIImageView?
    @IBAction func saveImage() {
        UIImageWriteToSavedPhotosAlbum(original!, nil, nil, nil)
    }
}
