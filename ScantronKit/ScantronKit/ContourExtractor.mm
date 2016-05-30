//
//  ContourExtractor.m
//  ScantronKit
//
//  Created by Nate Parrott on 8/3/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "ContourExtractor.h"
#import <opencv2/opencv.hpp>
#import <ios.h>
#import "InstaGrade_Scanner-Swift.h"
#import <GPUImage.h>
#import "Logging.h"

CGFloat SKNormalizeAngle(CGFloat angle) {
    angle = fmodf(angle, M_PI * 2);
    if (angle < -M_PI) angle += M_PI * 2;
    else if (angle > M_PI) angle -= M_PI * 2;
    return angle;
}

#define DEGREES(x) ((x) * M_PI / 180)

NSString* SKGetContourPattern(std::vector<cv::Point> points, double *irregularity, bool reverseDirection, NSMutableArray *pointMap) {
    *irregularity = 0;
    CGFloat directionLeftovers = 0;
    NSMutableString *directions = [NSMutableString new];
    CGFloat prevAngle = 0;
    NSInteger len = points.size();
    for (int i=0; i<=len; i++) {
        cv::Point p1 = points[reverseDirection? len - i%len : i%len];
        cv::Point p2 = points[reverseDirection? len - (i+1)%len : (i+1)%len];
        CGFloat angle = atan2f(p2.y - p1.y, p2.x - p1.x);
        if (i > 0) {
            directionLeftovers += angle - prevAngle;
            BOOL add = NO;
            while (SKNormalizeAngle(directionLeftovers) > DEGREES(50)) {
                [directions appendString:@"R"];
                directionLeftovers -= DEGREES(90);
                add = YES;
            }
            while (SKNormalizeAngle(directionLeftovers) < DEGREES(-50)) {
                [directions appendString:@"L"];
                directionLeftovers += DEGREES(90);
                add = YES;
            }
            if (add) {
                [pointMap addObject:[NSValue valueWithCGPoint:CGPointMake(p1.x, p1.y)]];
            }
        }
        prevAngle = angle;
    }
    return directions;
}

CGPoint SKClosestPoint(std::vector<cv::Point> &cvContour, CGPoint p) {
    CGPoint closest;
    CGFloat bestDistance = -1;
    NSInteger size = cvContour.size();
    for (NSInteger i=0; i<size; i++) {
        cv::Point point = cvContour[i];
        CGFloat dist = sqrtf(powf(point.x - p.x, 2) + powf(point.y - p.y, 2));
        if (bestDistance == -1 || dist < bestDistance) {
            closest = CGPointMake(point.x, point.y);
            bestDistance = dist;
        }
    }
    return closest;
}

@implementation Contour

- (instancetype)initWithCVContour:(std::vector<cv::Point>&)cvContour {
    self = [super init];
    self.area = cv::contourArea(cvContour, false);
    bool reverse = false;
    if (self.area < 0) {
        self.area = -self.area;
        reverse = true;
    }
    double irregularity;
    NSMutableArray *points = [NSMutableArray new];
    self.pattern = SKGetContourPattern(cvContour, &irregularity, reverse, points);
    self.irregularity = irregularity;
    self.points = points;
    return self;
}

- (CGPoint)averagePoint {
    CGPoint a = CGPointZero;
    for (int i=0; i<self.points.count; i++) {
        CGPoint p = [self.points[i] CGPointValue];
        a.x += p.x;
        a.y += p.y;
    }
    return a;
}

@end

void fastAdaptiveThreshold(cv::Mat& input) {
    int radius = (int)[[Tracking new] thresholdRadius];
    if (radius % 2 == 0) radius++; // ensure odd #
    int idelta = 10;
    vImage_Buffer vInput;
    vInput.width = input.size().width;
    vInput.height = input.size().height;
    vInput.rowBytes = vInput.width;
    vInput.data = input.data;
    
    vImage_Buffer vOutput;
    vOutput.width = input.size().width;
    vOutput.height = input.size().height;
    vOutput.rowBytes = vInput.width;
    vOutput.data = malloc(vOutput.rowBytes * vOutput.height);
    
    vImageBoxConvolve_Planar8(&vInput, &vOutput, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
    vImageBoxConvolve_Planar8(&vInput, &vOutput, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
    vImageBoxConvolve_Planar8(&vInput, &vOutput, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
    
    for (int y=0; y<vInput.height; y++) {
        UInt8 *imageRow = (UInt8 *)vInput.data + y * vInput.rowBytes;
        UInt8 *meanRow = (UInt8 *)vOutput.data + y * vOutput.rowBytes;
        for (int x=0; x<vInput.height; x++) {
            imageRow[x] = imageRow[x] > meanRow[x] - idelta ? 255 : 0;
        }
    }
    
    free(vOutput.data);
}

void testThresholdSpeed(cv::Mat edges) {
    // warm up your caches
    cv::adaptiveThreshold(edges, edges, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, (int)[[Tracking new] thresholdRadius], 10);
    
    int runs = 100;
    NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
    for (int i=0; i<runs; i++) {
        cv::adaptiveThreshold(edges, edges, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, (int)[[Tracking new] thresholdRadius], 10);
    }
    NSTimeInterval cvRuntime = [NSDate timeIntervalSinceReferenceDate] - startTime;
    
    // warm up your caches
    fastAdaptiveThreshold(edges);
    
    startTime = [NSDate timeIntervalSinceReferenceDate];
    for (int i=0; i<runs; i++) {
        fastAdaptiveThreshold(edges);
    }
    NSTimeInterval customRuntime = [NSDate timeIntervalSinceReferenceDate] - startTime;
    
    NSLog(@"%i runs took %f seconds w/ openCV and %f seconds w/ custom function", runs, cvRuntime, customRuntime);
    
}

void UIImageToMat_Alternate(const UIImage* image,
                  cv::Mat& m, bool alphaExist) {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width, rows = image.size.height;
    CGContextRef contextRef;
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    if (CGColorSpaceGetModel(colorSpace) == 0)
    {
        m.create(rows, cols, CV_8UC1); // 8 bits per component, 1 channel
        bitmapInfo = kCGImageAlphaNone;
        if (!alphaExist)
            bitmapInfo = kCGImageAlphaNone;
        contextRef = CGBitmapContextCreate(m.data, m.cols, m.rows, 8,
                                           m.step[0], colorSpace,
                                           bitmapInfo);
    }
    else
    {
        m.create(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
        if (!alphaExist)
            bitmapInfo = kCGImageAlphaNoneSkipLast |
            kCGBitmapByteOrderDefault;
        contextRef = CGBitmapContextCreate(m.data, m.cols, m.rows, 8,
                                           m.step[0], colorSpace,
                                           bitmapInfo);
    }
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows),
                       image.CGImage);
    CGContextRelease(contextRef);
}

@implementation ContourExtractor

- (void)extractContoursFromImage:(UIImage *)image callback:(void(^)(NSArray *contours))callback {
    
    NSInteger contourMinEdgeCount = [[Tracking new] contourMinEdgeCount];
    CGFloat imageArea = image.size.width * image.size.height;
    cv::Mat color;
    UIImageToMat_Alternate(image, color, false);
    cv::Mat edges;
    cv::cvtColor(color, edges, CV_RGBA2GRAY);
    
    //cv::adaptiveThreshold(edges, edges, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, (int)[[Tracking new] thresholdRadius], 10);
    fastAdaptiveThreshold(edges);
    //testThresholdSpeed(edges);
    
    if (DEBUGMODE()) {
        LOGImage(MatToUIImage(edges), @"edges");
    }
    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(edges, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
    
    /*if (DEBUGMODE()) {
        cv::Mat drawContours(color);
        cv::drawContours(drawContours, contours, -1, cv::Scalar(255,0,0));
        LOGImage(MatToUIImage(drawContours), @"contours");
    }*/
    NSMutableArray *contourObjs = [NSMutableArray new];
    for (int i=0; i<contours.size(); i++) {
        CGFloat area = cv::contourArea(contours[i]);
        if (area/imageArea < 0.001) continue;
        cv::approxPolyDP(contours[i], contours[i], cv::arcLength(contours[i], true) * 0.008, true);
        if (contours[i].size() >= contourMinEdgeCount) {
            Contour *ct = [[Contour alloc] initWithCVContour:contours[i]];
            [contourObjs addObject:ct];
        }
    }
    if (DEBUGMODE()) {
        cv::Mat polygons(color);
        cv::drawContours(polygons, contours, -1, cv::Scalar(255,0,0));
        LOGImage(MatToUIImage(polygons), @"polygons");
    }
    callback(contourObjs);
}

@end
