//
//  PointsPickerView.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/22/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class PointsPickerView: UIView {
    var maxPoints: Double = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    var onAssignedPoints: ((Double) -> ())?
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        // TODO: actually work
        if let callback = onAssignedPoints {
            callback(maxPoints)
        }
    }
}
