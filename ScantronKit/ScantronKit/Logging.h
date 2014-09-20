//
//  Logging.h
//  ScantronKit
//
//  Created by Nate Parrott on 9/18/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN BOOL IS_SIMULATOR();
UIKIT_EXTERN BOOL DEBUGMODE();
UIKIT_EXTERN void LOG(NSString *text);
UIKIT_EXTERN void LOGImage(UIImage *image, NSString *name);
