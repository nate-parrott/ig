//
//  SKMath.h
//  ScantronKit
//
//  Created by Nate Parrott on 8/9/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKMath : NSObject

+ (CATransform3D)reverseProjectionTransformationWithQuad:(CGPoint[4])points;

@end
