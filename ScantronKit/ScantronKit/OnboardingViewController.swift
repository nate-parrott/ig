//
//  OnboardingViewController.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/28/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController, UIScrollViewDelegate {
    
    var viewsAndPagesTheyAppearOn: [(UIView, CGFloat)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        for i in 0..<4 {
            let viewController = storyboard.instantiateViewControllerWithIdentifier("Page\(i+1)")! as UIViewController
            let view = viewController.view
            addChildViewController(viewController)
            scrollView.addSubview(view)
            pages.append(viewController)
        }
        let paper = storyboard.instantiateViewControllerWithIdentifier("Paper")! as UIViewController
        paperView = paper.view
        scrollView.addSubview(paperView)
        scrollView.bringSubviewToFront(pages[2].view)
        
        viewsAndPagesTheyAppearOn += [(paper.view.viewWithTag(1)!, 0.6)] // name
        viewsAndPagesTheyAppearOn += [(paper.view.viewWithTag(2)!, 0.6)] // scribble1
        viewsAndPagesTheyAppearOn += [(paper.view.viewWithTag(3)!, 0.8)] // scribble2
        viewsAndPagesTheyAppearOn += [(paper.view.viewWithTag(4)!, 1.0)] // scribble3
        viewsAndPagesTheyAppearOn += [(paper.view.viewWithTag(5)!, 2.9)] // grade
        
        scrollViewDidScroll(scrollView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Mixpanel.sharedInstance().track("ShownOnboarding")
    }
    
    var pages: [UIViewController] = []
    var paperView: UIView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var i = 0
        for childVC in pages {
            childVC.view.frame = CGRectMake(CGFloat(i) * view.bounds.size.width, 0, view.bounds.size.width, view.bounds.size.height)
            i++
        }
        scrollView.contentSize = CGSizeMake(CGFloat(i) * view.bounds.size.width, view.bounds.size.height)
        scrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / view.bounds.size.width
        if page >= CGFloat(countElements(pages)) && !loggedFinishOnboardingSwiping {
            loggedFinishOnboardingSwiping = true
            Mixpanel.sharedInstance().track("FinishSwipingOnboarding")
        }
        let viewFadeInDuration: CGFloat = 0.6
        for (transientView, doneWithFade) in viewsAndPagesTheyAppearOn {
            let startFade = doneWithFade - viewFadeInDuration
            var alpha: CGFloat = 0.0
            if page >= doneWithFade {
                alpha = 1
            } else if page >= startFade {
                alpha = (page - startFade) / viewFadeInDuration
            }
            transientView.alpha = alpha
        }
        paperView.center = scrollView.convertPoint(CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2), fromView: view)
        pageControl.currentPage = Int(round(Float(page)))
    }
    
    var loggedStartOnboardingSwiping = false
    var loggedFinishOnboardingSwiping = false
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if !loggedStartOnboardingSwiping {
            loggedStartOnboardingSwiping = true
            Mixpanel.sharedInstance().track("StartSwipingOnboarding")
        }
    }
    
    @IBOutlet var scrollView: UIScrollView!

    @IBOutlet var pageControl: UIPageControl!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidDisappear(animated: Bool) {
        /*
        this is some DUMB SHIT that's necessary to work around a fucking
        AUTO-LAYOUT CRASH that i DON'T UNDERSTAND
        */
        super.viewDidDisappear(animated)
        for page in pages {
            page.view.removeFromSuperview()
        }
        scrollView.removeFromSuperview()
    }
}
