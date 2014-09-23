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
    }
}
