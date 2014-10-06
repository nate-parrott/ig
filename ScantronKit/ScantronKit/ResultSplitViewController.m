//
//  ResultSplitViewController.m
//  ScantronKit
//
//  Created by Nate Parrott on 10/5/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "ResultSplitViewController.h"
#import "InstaGrade_Scanner-Swift.h"

@implementation ResultSplitViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.delegate = self;
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
}

- (void)showDetailViewController:(UIViewController *)vc sender:(id)sender {
    if (self.isCollapsed) {
        [self.viewControllers[0] pushViewController:vc animated:YES];
    } else {
        self.viewControllers = @[self.viewControllers[0], [[UINavigationController alloc] initWithRootViewController:vc]];
    }
}

#pragma mark Split -> Single VC

- (UIViewController *)primaryViewControllerForCollapsingSplitViewController:(UISplitViewController *)splitViewController {
    return self.viewControllers[0];
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    UINavigationController *primaryNav = (UINavigationController *)primaryViewController;
    UINavigationController *secondaryNav = (UINavigationController *)secondaryViewController;
    if ([secondaryNav.viewControllers.lastObject isKindOfClass:[IndividualResultTableViewController class]]) {
        // collapse the detail VC onto the nav stack:
        [primaryNav pushViewController:secondaryNav.viewControllers.lastObject animated:NO];
    }
    return YES;
}

#pragma mark Single -> Split VC
- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController {
    UINavigationController *nav = (UINavigationController *)primaryViewController;
    UIViewController *lastViewControllerOnNavStack = nav.viewControllers.lastObject;
    if ([lastViewControllerOnNavStack isKindOfClass:[IndividualResultTableViewController class]]) {
        [nav popViewControllerAnimated:NO];
        return [[UINavigationController alloc] initWithRootViewController:lastViewControllerOnNavStack];
    } else {
        // create an empty detail VC:
        UIViewController *vc = [UIViewController new];
        vc.view = [UIView new];
        vc.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
        return [[UINavigationController alloc] initWithRootViewController:vc];
    }
}

@end
