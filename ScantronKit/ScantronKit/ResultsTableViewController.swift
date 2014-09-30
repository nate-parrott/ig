//
//  ResultsTableViewController.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/15/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class ResultsTableViewController: SwipeAwayTableViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
        logoutButton.setTitle(NSString(format: NSLocalizedString("Log out %@", comment: ""), SharedAPI().userEmail!), forState: UIControlState.Normal)
        if let selectedIndexPath = tableView.indexPathForSelectedRow() {
            tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
    
    var sections: [[QuizInstance]] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func topMargin() -> CGFloat {
        return 50
    }
    
    func groupInstancesByQuiz(instances: [QuizInstance]) -> [[QuizInstance]] {
        if let first = instances.first {
            let firstQuiz = first.quiz!
            for i in 0..<countElements(instances) {
                if instances[i].quiz != firstQuiz {
                    let group = Array(instances[0..<i])
                    let leftover = Array(instances[i..<countElements(instances)])
                    return [group] + groupInstancesByQuiz(leftover)
                }
            }
            // these are all from the same quiz:
            return [instances]
        } else {
            return []
        }
    }
    
    func reloadData() {
        let fetchReq = NSFetchRequest(entityName: "QuizInstance")
        fetchReq.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let instances = SharedCoreDataManager().managedObjectContext!.executeFetchRequest(fetchReq, error: nil)! as [QuizInstance]
        sections = groupInstancesByQuiz(instances)
    }
    
    // MARK: TableView
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return countElements(sections)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].first!.quiz.title
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countElements(sections[section])
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("QuizInstanceCell", forIndexPath: indexPath) as QuizInstanceCell
        cell.quizInstance = sections[indexPath.section][indexPath.row]
        return cell
    }
        
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == countElements(sections) - 1 {
            return "We've emailed you more detailed results and analysis at \(SharedAPI().userEmail!)"
        }
        return nil
    }
    
    @IBAction func logout() {
        SharedAPI().logOut()
    }
    
    // MARK: Layout
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    @IBOutlet var logoutButton: UIButton!
    
    // MARK: Detail
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "QuizDetail" {
            let detailVC = segue.destinationViewController as IndividualResultTableViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow()!
            detailVC.quizInstance = sections[selectedIndexPath.section][selectedIndexPath.row]
            detailVC.transitioningDelegate = detailVC
            detailVC.modalPresentationStyle = UIModalPresentationStyle.Custom
        }
    }
}
