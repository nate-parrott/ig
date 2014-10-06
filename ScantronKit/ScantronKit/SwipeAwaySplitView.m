//
//  SwipeAwaySplitView.m
//  ScantronKit
//
//  Created by Nate Parrott on 10/4/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "SwipeAwaySplitView.h"
#import <FBKVOController.h>

@interface SwipeAwaySplitView ()

@property (nonatomic) BOOL setupYet;
@property (nonatomic) FBKVOController *kvoController;

@end

@implementation SwipeAwaySplitView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.transitioningDelegate = self;
    self.modalPresentationStyle = UIModalPresentationCustom;
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setup];
}

- (void)setup {
    if (self.setupYet) return;
    self.setupYet = YES;
    self.view.backgroundColor = [UIColor clearColor];
    self.kvoController = [FBKVOController controllerWithObserver:self];
}

#pragma mark Animations
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.6;
}
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *container = [transitionContext containerView];
    BOOL presentation = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey] == self;
    if (presentation) {
        [container addSubview:self.view];
        self.view.frame = [transitionContext finalFrameForViewController:self];
        self.view.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            self.view.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    } else {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            self.view.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }
}

#pragma mark Dismissal
- (void)registerScrollViewForDismissGesture:(UIScrollView *)scrollView {
    [self setupYet];
    [self.kvoController observe:scrollView keyPath:@"contentOffset" options:0 block:^(id observer, id object, NSDictionary *change) {
        CGFloat progress = -[object contentOffset].y / self.view.bounds.size.height;
        progress = MIN(1, MAX(0, progress));
        [self setDismissalGestureProgress:progress associatedView:object];
    }];
}
- (void)setDismissalGestureProgress:(CGFloat)progress associatedView:(UIScrollView *)scrollView {
    for (UIViewController *vc in self.viewControllers) {
        if ([[self class] viewController:vc containsView:scrollView]) {
            // do nothing
        } else {
            vc.view.transform = CGAffineTransformMakeTranslation(0, progress * self.view.bounds.size.height);
        }
    }
}
#pragma mark Helpers
+ (BOOL)viewController:(UIViewController *)vc containsView:(UIView *)view {
    while (view) {
        if (vc.view == view) {
            return YES;
        }
        view = view.superview;
    }
    return NO;
}

@end
