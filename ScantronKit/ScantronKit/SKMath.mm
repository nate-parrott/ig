//
//  SKMath.m
//  ScantronKit
//
//  Created by Nate Parrott on 8/9/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "SKMath.h"
#import <opencv.hpp>

CATransform3D transform3dFromPerspectiveMat(CvMat* mat) {
#define H(r,c) (cvmGet(mat, r, c))
    
    /*float matrix[16] = {H(0,0), H(0,1), 0, H(0,2),
     H(1,0), H(1,1), 0, H(1,2),
     0,      0, 1,      0,
     H(2,0), H(2,1), 0, H(2,2)};*/
    CATransform3D t;
    t.m11 = H(0,0);
    t.m21 = H(0,1);
    t.m31 = 0;
    t.m41 = H(0,2);
    t.m12 = H(1,0);
    t.m22 = H(1,1);
    t.m32 = 0;
    t.m42 = H(1,2);
    t.m13 = 0;
    t.m23 = 0;
    t.m33 = 1;
    t.m43 = 0;
    t.m14 = H(2,0);
    t.m24 = H(2,1);
    t.m34 = 0;
    t.m44 = H(2,2);
    return t;
}

@implementation SKMath

+ (CATransform3D)reverseProjectionTransformationWithQuad:(CGPoint[4])points {
    CvPoint2D32f corners[4];
    for (int i=0; i<4; i++) {
        corners[i].x = points[i].x;
        corners[i].y = points[i].y;
    }
    CvPoint2D32f targets[4];
    targets[0] = cvPoint2D32f(0, 0);
    targets[1] = cvPoint2D32f(1, 0);
    targets[2] = cvPoint2D32f(1, 1);
    targets[3] = cvPoint2D32f(0, 1);
    for (int i=0; i<4; i++) {
        //corners[i].y = 1-corners[i].y;
        //targets[i].y = 1-targets[i].y;
        //corners[i].x = 1-corners[i].x;
    }
    CvMat* transform = cvCreateMat(3, 3, CV_32FC1); // !FREE
    cvGetPerspectiveTransform(corners, targets, transform);
    CATransform3D transform3d = transform3dFromPerspectiveMat(transform);
    cvReleaseMat(&transform);
    return transform3d;
}

@end
