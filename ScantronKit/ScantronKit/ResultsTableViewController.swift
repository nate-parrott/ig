//
//  ResultsTableViewController.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/15/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class ResultsTableViewController: UITableViewController {
    
    @IBAction func dismiss() {
        navigationController!.parentViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Mixpanel.sharedInstance().track("ShownResultsViewController")
        reloadData()
        emailLabel.text = SharedAPI().userEmail
        paymentsButton.setTitle(SharedAPI().usageLeftSummary(), forState: UIControlState.Normal)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
        
    }
    
    @IBAction func showHelp() {
        let browser = PBWebViewController()
        Mixpanel.sharedInstance().track("ClickedHelp")
        browser.URL = NSURL(string: "http://instagradeapp.com/help")
        let nav = UINavigationController(rootViewController: browser)
        browser.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "dismissBrowser")
        presentViewController(nav, animated: true, completion: nil)
    }
    
    func dismissBrowser() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    var sections: [[QuizInstance]] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    func groupInstancesByQuiz(instances: [QuizInstance]) -> [[QuizInstance]] {
        if let first = instances.first {
            let firstQuiz = first.quiz!
            for i in 0..<instances.count {
                if instances[i].quiz != firstQuiz {
                    let group = Array(instances[0..<i])
                    let leftover = Array(instances[i..<instances.count])
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
        let instances = try! SharedCoreDataManager().managedObjectContext!.executeFetchRequest(fetchReq) as! [QuizInstance]
        sections = groupInstancesByQuiz(instances)
    }
    
    // MARK: TableView
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].first!.quiz?.title
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("QuizInstanceCell", forIndexPath: indexPath) as! QuizInstanceCell
        cell.quizInstance = sections[indexPath.section][indexPath.row]
        return cell
    }
        
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == sections.count - 1 {
            return "We've emailed you more detailed results and analysis at \(SharedAPI().userEmail!)"
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    @IBAction func logout() {
        SharedAPI().logOut()
    }
    
    // MARK: Layout
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var paymentsButton: UIButton!
    
    // MARK: Detail
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "QuizDetail" {
            let detailVC = segue.destinationViewController as! IndividualResultTableViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            detailVC.quizInstance = sections[selectedIndexPath.section][selectedIndexPath.row]
            detailVC.didDeleteItem = {
                [weak self]
                () in
                if let s = self {
                    s.reloadData()
                }
            }
        }
    }
}
