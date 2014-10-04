//
//  UIImage+Crop.m
//  ScantronKit
//
//  Created by Nate Parrott on 10/4/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "UIImage+Crop.h"

double UIImageCropRad(double deg)
{
    return deg / 180.0 * M_PI;
}

UIImage* UIImageCrop(UIImage* img, CGRect rect)
{
    CGAffineTransform rectTransform;
    switch (img.imageOrientation)
    {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(UIImageCropRad(90)), 0, -img.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(UIImageCropRad(-90)), -img.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(UIImageCropRad(-180)), -img.size.width, -img.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    rectTransform = CGAffineTransformScale(rectTransform, img.scale, img.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], CGRectApplyAffineTransform(rect, rectTransform));
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:img.scale orientation:img.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

@implementation UIImage (Crop)

- (UIImage*)cropped:(CGRect)rect {
    return UIImageCrop(self, rect);
}

@end
