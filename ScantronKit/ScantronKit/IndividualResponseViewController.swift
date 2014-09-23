//
//  IndividualResponseViewController.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/22/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class IndividualResponseViewController: UIViewController {
    @IBOutlet var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var imageAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var questionNumberLabel: UILabel!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var pointsView: PointsPickerView!
    
    var responseItem: QuizItemManuallyGradedResponse!
    var index: Int!
    var scannedPages: [ScannedPage]!
    
    func setup() {
        let questionNum = responseItem.item.getOrDefault("visibleIndex", defaultVal: 0) as Int
        questionNumberLabel.text = "Question \(questionNum)"
        questionLabel.text = responseItem.item.getOrDefault("description", defaultVal: "") as? String
        let pageImage = scannedPages[responseItem.frame.page].image
        let responseSnapshot = pageImage.subImage(responseItem.frame.toRect(pageImage.size))
        imageView.image = responseSnapshot
        imageViewHeightConstraint.constant = responseSnapshot.size.height
        imageAspectRatioConstraint.constant = responseSnapshot.size.width / responseSnapshot.size.height
        pointsView.maxPoints = responseItem.pointValue
        pointsView.selectedValue = responseItem.earnedPoints
    }
}
