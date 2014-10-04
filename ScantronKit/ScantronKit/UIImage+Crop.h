//
//  UIImage+Crop.h
//  ScantronKit
//
//  Created by Nate Parrott on 10/4/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Crop)

- (UIImage*)cropped:(CGRect)rect;

@end
