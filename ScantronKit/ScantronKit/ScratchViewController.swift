//
//  ScratchViewController.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/23/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class ScratchViewController: UIViewController {

    @IBOutlet var pointsPickerView: PointsPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pointsPickerView.maxPoints = 1
        
        let names = ["blur0", "blur1", "blur2"]
        let images = names.map({ UIImage(named: $0) })
        for method in ["slow", "fast"] {
            print("METHOD: \(method)")
            for (image, name) in Zip2Sequence(images, names) {
                let data = image!.pixelData()
                let blurriness = method == "fast" ? data.fastBlurrinessMetric() : data.blurrinessMetric()
                print(" \(name): \(blurriness)")
            }
        }
    }
}
