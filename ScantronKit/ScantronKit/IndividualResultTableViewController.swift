//
//  IndividualResultTableViewController.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/30/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit


@objc class IndividualResultTableViewController: UITableViewController {
    
    var quizInstance: QuizInstance? {
        didSet {
            let quizItems = quizInstance!.itemsWithResponses as [QuizItem]
            visibleQuizItems = quizItems.filter({ $0.getOrDefault("visibleIndex", defaultVal: -1) as Int != -1})
            tableView.reloadData()
        }
    }
    
    var visibleQuizItems: [QuizItem] = []

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return countElements(visibleQuizItems)
        default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let quizInstanceCell = tableView.dequeueReusableCellWithIdentifier("QuizInstanceCell", forIndexPath: indexPath) as QuizInstanceCell
            quizInstanceCell.quizInstance = self.quizInstance
            return quizInstanceCell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("QuizItemCell", forIndexPath: indexPath) as QuizItemCell
            cell.quizItem = visibleQuizItems[indexPath.row]
            return cell
        default:
            return tableView.dequeueReusableCellWithIdentifier("this will never fucking happen but i've gotta return something don't i?", forIndexPath: indexPath) as UITableViewCell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "Answers"
        default: return nil
        }
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 1: return "We've emailed you a more detailed report."
        default: return nil
        }
    }
}

class QuizItemCell : UITableViewCell {
    @IBOutlet var index: UILabel!
    @IBOutlet var question: UILabel!
    @IBOutlet var gradingDescription: UILabel!
    @IBOutlet var points: UILabel!
    var quizItem: QuizItem? {
        didSet {
            println("\(quizItem!)")
            let earned = quizItem!.getOrDefault("pointsEarned", defaultVal: 0) as Double
            let maxPoints = quizItem!.getOrDefault("points", defaultVal: 0) as Double
            points.text = "\(earned)/\(maxPoints)"
            points.textColor = (earned < maxPoints) ? tintColor : UIColor.blackColor()
            question.text = quizItem!.getOrDefault("description", defaultVal: "") as? String
            gradingDescription.text = quizItem!.getOrDefault("gradingDescription", defaultVal: "") as? String
            let idx = quizItem!.getOrDefault("visibleIndex", defaultVal: 0) as Int
            index.text = "\(idx)"
        }
    }
}


