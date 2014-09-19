//
//  Logging.m
//  ScantronKit
//
//  Created by Nate Parrott on 9/18/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "Logging.h"

BOOL DEBUGMODE() {
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    return NO;
#endif
}
void LOG(NSString *text) {
    if (DEBUGMODE()) {
        NSLog(@"%@", text);
    }
}
void LOGImage(UIImage *image, NSString *name) {
    if (DEBUGMODE()) {
        [UIImagePNGRepresentation(image) writeToFile:[[@"/Users/nateparrott/Desktop" stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"png"] atomically:YES];
    }
}