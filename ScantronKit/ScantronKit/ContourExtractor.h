//
//  ContourExtractor.h
//  ScantronKit
//
//  Created by Nate Parrott on 8/3/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Contour : NSObject

@property (nonatomic) NSString *pattern;
@property (nonatomic) double area, irregularity;
@property (nonatomic) NSArray *points;
- (CGPoint)averagePoint;

@end


@interface ContourExtractor : NSObject

- (void)extractContoursFromImage:(UIImage *)image callback:(void(^)(NSArray *contours))callback;

@end
