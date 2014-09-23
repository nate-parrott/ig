//
//  PointsPickerView.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/22/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

let PointsPickerViewCircleSize: CGFloat = 34

class PointsPickerCircleView: UIView {
    init(number: Double) {
        super.init(frame: CGRectMake(0, 0, PointsPickerViewCircleSize, PointsPickerViewCircleSize))
        backgroundColor = UIColor.blackColor()
        layer.cornerRadius = PointsPickerViewCircleSize / 2
        let label = UILabel(frame: bounds)
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.boldSystemFontOfSize(16)
        label.textAlignment = NSTextAlignment.Center
        label.text = NSString(format: "%g", number)
        label.adjustsFontSizeToFitWidth = true
        addSubview(label)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class PointsPickerMarkerView: UIView {
    var value: Double = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    let minLabelWidth: CGFloat = 10
    
    var label: UILabel?
    var labelBackground: UIView?
    var labelPadding: CGFloat = 2
    
    override func drawRect(rect: CGRect) {
        if label == nil {
            labelBackground = UIView()
            addSubview(labelBackground!)
            labelBackground!.backgroundColor = tintColor
            
            label = UILabel()
            addSubview(label!)
            label!.textColor = UIColor.whiteColor()
            label!.font = UIFont.boldSystemFontOfSize(12)
        }
        
        let path = UIBezierPath()
        tintColor.setFill()
        path.moveToPoint(CGPointZero)
        path.addLineToPoint(CGPointMake(0, bounds.size.height))
        
        label!.text = NSString(format: "%g", value)
        label!.sizeToFit()
        labelBackground!.frame = CGRectMake(0, 0, label!.frame.size.width + labelPadding * 2, label!.frame.size.height + labelPadding * 2)
        label!.frame = CGRectMake(labelPadding, labelPadding, max(minLabelWidth, label!.frame.size.width), label!.frame.size.height)
        
        path.addLineToPoint(CGPointMake(minLabelWidth, labelBackground!.frame.size.height))
        
        path.closePath()
        path.fill()
    }
}


class PointsPickerView: UIView {
    var maxPoints: Double = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    var selectedValue: Double? {
        didSet {
            setNeedsLayout()
        }
    }
    var onAssignedPoints: ((Double) -> ())?
    
    var marker: PointsPickerMarkerView!
    
    let xPadding: CGFloat = 30
    func valueForX(pos: CGFloat, precise: Bool) -> Double {
        let mapped = Double(max(0, min(1, (pos - xPadding) / (bounds.size.width - xPadding * 2)))) * maxPoints
        let rounding = pow(10, round(log10(maxPoints)) - 1)
        return round(mapped / rounding) * rounding
    }
    
    var circles: [PointsPickerCircleView] = []
    override func drawRect(rect: CGRect) {
        
        for oldCircle in circles {
            oldCircle.removeFromSuperview()
        }
        
        let numCircles = Int(floor(self.bounds.size.width / (PointsPickerViewCircleSize + 40)) + 1)
        let circleWidth = bounds.size.width / CGFloat(numCircles)
        
        for i in 0...numCircles {
            let x: CGFloat = (bounds.size.width - xPadding*2) / CGFloat(numCircles) * CGFloat(i) + xPadding
            let circleView = PointsPickerCircleView(number: valueForX(x, precise: false))
            addSubview(circleView)
            circles.append(circleView)
            circleView.center = CGPointMake(x, bounds.size.height/2)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // update marker:
        if let val = selectedValue {
            let xForValue = CGFloat(val / maxPoints) * (bounds.size.width - xPadding * 2) + xPadding
            if marker? == nil {
                marker = PointsPickerMarkerView(frame: CGRectMake(0, 0, 0, 0))
                addSubview(marker)
                marker.userInteractionEnabled = false
                marker.backgroundColor = UIColor.clearColor()
            }
            bringSubviewToFront(marker)
            marker.frame = CGRectMake(xForValue, -5, 10, bounds.size.height - 10)
            marker.value = val
        } else {
            marker.removeFromSuperview()
            marker = nil
        }
    }
}
