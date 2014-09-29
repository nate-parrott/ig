//
//  IndividualResponseViewController.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/22/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class IndividualResponseViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var questionNumberLabel: UILabel!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var pointsView: PointsPickerView!
    @IBOutlet var pointsViewLabel: UILabel!
    
    var responseItem: QuizItemManuallyGradedResponse!
    var quiz: Quiz!
    var index: Int!
    var scannedPages: [ScannedPage]!
    
    func setup() {
        let questionNum = responseItem.item.getOrDefault("visibleIndex", defaultVal: 0) as Int
        questionNumberLabel.text = "Question \(questionNum)"
        questionLabel.text = responseItem.item.getOrDefault("description", defaultVal: "") as? String
        let pageImage = scannedPages[responseItem.frame.page].image
        let responseSnapshot = responseItem.frame.extract(pageImage, aspectRatio: quiz.aspectRatio)
        imageView.image = responseSnapshot
        pointsView.maxPoints = responseItem.pointValue
        pointsView.selectedValue = responseItem.earnedPoints
        view.setNeedsLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        questionNumberLabel.sizeToFit()
        let p: CGFloat = 10
        questionNumberLabel.top = topLayoutGuide.length + p
        questionNumberLabel.left = p
        questionLabel.size = questionLabel.sizeThatFits(CGSizeMake(view.width - p * 2, 200))
        pointsView.frame = CGRectMake(0, view.height - p - 50, view.width, 50)
        pointsViewLabel.sizeToFit()
        pointsViewLabel.left = p
        pointsViewLabel.top = pointsView.top - pointsViewLabel.height
        imageView.top = questionLabel.bottom + p
        imageView.left = p
        let availableImageSize = CGSizeMake(view.width-p - imageView.left, pointsViewLabel.top-p - imageView.top)
        let imageSize = imageView.image!.size
        let scale = min(1, min(availableImageSize.width / imageSize.width, availableImageSize.height / imageSize.height))
        imageView.size = CGSizeMake(scale * imageSize.width, scale * imageSize.height)
        println("avail: \(availableImageSize), image: \(imageSize), scale: \(scale), frame: \(imageView.frame)")
    }
}
