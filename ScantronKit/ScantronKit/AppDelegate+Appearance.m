//
//  AppDelegate+Appearance.m
//  ScantronKit
//
//  Created by Nate Parrott on 10/5/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "AppDelegate+Appearance.h"

void SetupAppearanceWithWindow(UIWindow *window) {
    window.tintColor = [UIColor colorWithRed:0.216 green:0.573 blue:0.518 alpha:1.000];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"GillSans" size:18.0]} forState:UIControlStateNormal];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"GillSans" size:18.0]}];
}

