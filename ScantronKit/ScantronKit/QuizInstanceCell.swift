//
//  QuizInstanceCell.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/26/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class QuizInstanceCell: UITableViewCell {

    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var nameImageView: UIImageView!
    
    var quizInstance: QuizInstance? {
        didSet {
            if let q = quizInstance {
                scoreLabel.text = "\(q.earnedScore)/\(q.maximumScore)"
                nameImageView.image = q.nameImage()
            }
        }
    }
}
