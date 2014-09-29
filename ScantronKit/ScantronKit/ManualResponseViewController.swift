//
//  ManualResponseViewController.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/22/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class ManualResponseViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func setupWithItems(items: [QuizItemManuallyGradedResponse?], pages: [ScannedPage], quiz: Quiz) {
        responseItems = items
        scannedPages = pages
        self.quiz = quiz
        dataSource = self
        setViewControllers([viewControllerAtIndex(nextNonEmptyIndexAfter(-1)!)], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        // UIImageWriteToSavedPhotosAlbum(scannedPages.first!.image, nil, nil, nil)
    }
    
    var responseItems: [QuizItemManuallyGradedResponse?]!
    var scannedPages: [ScannedPage]!
    var quiz: Quiz!
    
    func viewControllerAtIndex(index: Int) -> IndividualResponseViewController {
        let vc = IndividualResponseViewController(nibName: "IndividualResponseViewController", bundle: nil)
        vc.responseItem = responseItems[index]!
        vc.index = index
        vc.scannedPages = scannedPages
        vc.quiz = quiz
        vc.loadView()
        vc.pointsView.onAssignedPoints = {
            [weak self, weak vc]
            (points: Double) in
            self!.responseItems[vc!.index]!.earnedPoints = points
            self!.advance()
        }
        vc.setup()
        return vc
    }
    
    func nextNonEmptyIndexAfter(var index: Int) -> Int? {
        index++
        while index < countElements(responseItems) {
            if responseItems[index] != nil {
                return index
            }
            index++
        }
        return nil
    }
    
    func previousNonEmptyIndexBefore(var index: Int) -> Int? {
        index--
        while index >= 0 {
            if responseItems[index] != nil {
                return index
            }
            index--
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let cur = viewController as IndividualResponseViewController
        if let prevIndex = previousNonEmptyIndexBefore(cur.index) {
            return viewControllerAtIndex(prevIndex)
        } else {
            return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let cur = viewController as IndividualResponseViewController
        let alreadyGotResponse = responseItems[cur.index]!.earnedPoints != nil
        if !alreadyGotResponse {
            return nil
        } else if let prevIndex = nextNonEmptyIndexAfter(cur.index) {
            return viewControllerAtIndex(prevIndex)
        } else {
            return nil
        }
    }
    
    func advance() {
        let nextVCOpt = pageViewController(self, viewControllerAfterViewController: self.viewControllers.first! as UIViewController)
        if let nextVC = nextVCOpt {
            setViewControllers([nextVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        } else {
            if let cb = self.onFinished {
                cb(responseItems)
            }
            navigationController!.dismissViewControllerAnimated(true, completion: onDismissalAnimationCompleted)
        }
    }
    
    @IBAction func cancel() {
        navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    var onFinished: ([QuizItemManuallyGradedResponse?] -> ())?
    var onDismissalAnimationCompleted: (() -> ())?
}
