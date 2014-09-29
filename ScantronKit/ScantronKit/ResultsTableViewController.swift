//
//  ResultsTableViewController.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/15/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class ResultsTableViewController: UITableViewController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    let topMargin: CGFloat = 50
    var contentBackdrop: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewDidScroll(tableView)
        
        tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, 1, topMargin))
        let tapRec = UITapGestureRecognizer(target: self, action: "dismiss")
        tableView.tableHeaderView!.addGestureRecognizer(tapRec)
        
        contentBackdrop = UIView()
        contentBackdrop.backgroundColor = UIColor.whiteColor()
        tableView.insertSubview(contentBackdrop, atIndex: 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
        view.setNeedsLayout()
        logoutButton.setTitle(NSString(format: NSLocalizedString("Log out %@", comment: ""), SharedAPI().userEmail!), forState: UIControlState.Normal)
    }
    
    var sections: [[QuizInstance]] = [] {
        didSet {
            tableView.reloadData()
        }
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
    
    // MARK: Transitioning
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.7
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let isDismissal = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) == self
        let duration = transitionDuration(transitionContext)
        let containerView = transitionContext.containerView()
        let dimmingView = UIView(frame: containerView.bounds)
        if isDismissal {
            containerView.insertSubview(dimmingView, belowSubview: self.view)
            dimmingView.backgroundColor = tableView.backgroundColor
            tableView.backgroundColor = UIColor.clearColor()
            UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: -dismissVelocity / containerView.height, options: nil, animations: { () -> Void in
                self.view.transform = CGAffineTransformMakeTranslation(0, containerView.height)
                dimmingView.alpha = 0
            }, completion: { (_) -> Void in
                self.view.removeFromSuperview()
                dimmingView.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        } else {
            containerView.addSubview(dimmingView)
            dimmingView.backgroundColor = UIColor.clearColor()
            containerView.addSubview(self.view)
            self.view.frame = transitionContext.finalFrameForViewController(self)
            self.view.transform = CGAffineTransformMakeTranslation(0, containerView.height)
            tableView.backgroundColor = UIColor.clearColor()
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.view.transform = CGAffineTransformIdentity
                dimmingView.backgroundColor = UIColor(white: 0.1, alpha: 0.5)
            }, completion: { (_) -> Void in
                dimmingView.removeFromSuperview()
                self.scrollViewDidScroll(self.tableView)
                transitionContext.completeTransition(true)
            })
        }
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == countElements(sections) - 1 {
            return "We've emailed you more detailed results and analysis at \(SharedAPI().userEmail!)"
        }
        return nil
    }
    
    // MARK: Interaction
    var isDismissing = false
    @IBAction func dismiss() {
        isDismissing = true
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    var dismissVelocity: CGFloat = 1
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.contentOffset.y < -10 && velocity.y < -1 {
            dismissVelocity = velocity.y
            dismiss()
        }
    }
    
    // MARK: Layout
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if !isDismissing {
            let scrollUpProportion: CGFloat = -scrollView.contentOffset.y / (view.height - topMargin)
            let fadeOut: CGFloat = min(1.0, max(0.0, scrollUpProportion))
            tableView.backgroundColor = UIColor(white: 0.1, alpha: (1 - fadeOut) * 0.5)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentBackdrop.frame = CGRectMake(0, topMargin, view.width, tableView.contentSize.height + view.height)
    }
    
    @IBOutlet var logoutButton: UIButton!
}
