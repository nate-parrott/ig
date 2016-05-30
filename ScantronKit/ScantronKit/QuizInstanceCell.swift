//
//  QuizInstanceCell.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/26/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

var _quizInstanceFakeIdentifyIndex: Int = 0

class QuizInstanceCell: UITableViewCell {

    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var nameImageView: UIImageView!
    
    var quizInstance: QuizInstance? {
        didSet {
            if let q = quizInstance {
                scoreLabel.text = "\(q.earnedScore!)/\(q.maximumScore!)"
                nameImageView.image = q.nameImage()
                if IS_SIMULATOR() && true {
                    _quizInstanceFakeIdentifyIndex += 1
                    let imageIndex = _quizInstanceFakeIdentifyIndex % 8
                    if imageIndex == 7 {
                        return
                    }
                    let r: Int = Int(rand())
                    let fakeEarned: Int = r % Int(q.maximumScore!) + 1
                    scoreLabel.text = "\(fakeEarned)/\(q.maximumScore)"
                    let path = "/Users/nateparrott/Documents/SW/instagrade-repo/Assets/example-names/name-\(imageIndex).png"
                    nameImageView.image = UIImage(contentsOfFile: path)
                }
            }
        }
    }
}
