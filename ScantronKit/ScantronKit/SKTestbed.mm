//
//  SKRectangleDetector.m
//  ScantronKit
//
//  Created by Nate Parrott on 7/30/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "SKTestbed.h"
#import <opencv2/opencv.hpp>
#import <ios.h>
#import <GPUImage.h>
#import "InstaGrade_Scanner-Swift.h"

cv::Point CG2CVPoint(CGPoint p) {
    return cv::Point(p.x, p.y);
}

@implementation SKTestbed

- (void)test {
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self testOutputDir]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[self testOutputDir] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSInteger i = 0;
    for (UIImage *largeImage in [self testImages]) {
        UIImage *image = [[Tracking new] resizeImage:largeImage];
        NSString *resultPath = [[self testOutputDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%li.png", (long)i++]];
        //[self annotateContours:image result:^(UIImage *result) {
        [self extractionTest:image result:^(UIImage *result) {
        //[self combTracer:image result:^(UIImage *result) {
            [UIImagePNGRepresentation(result) writeToFile:resultPath atomically:YES];
        }];
        //break;
    }
}

#pragma mark Algorithms

#define output(x) (callback(MatToUIImage(x)))

- (void)fullTest:(UIImage *)test result:(void(^)(UIImage *result))callback {
    [[Tracking new] testTracking:test callback:^(UIImage *image) {
        callback(image);
    }];
}

- (void)extractionTest:(UIImage *)test result:(void(^)(UIImage *result))callback {
    [[PageExtraction new] extract:test callback:^(UIImage *result) {
        callback(result);
    }];
}

- (void)annotateContours:(UIImage *)test result:(void(^)(UIImage *result))callback {
    [[Tracking new] annotateContours:test callback:^(UIImage *image) {
        callback(image);
    }];
}

- (void)stringyTriangleFinder:(UIImage *)test result:(void(^)(UIImage *result))callback {
    CGFloat maxDimension = 500;
    CGFloat scale = MIN(maxDimension / test.size.width, maxDimension / test.size.height);
    cv::Mat color;
    UIImageToMat(test, color);
    cv::Mat colorSmall;
    cv::resize(color, colorSmall, cv::Size(test.size.width * scale, test.size.height * scale));
    cv::Mat gray;
    cv::Mat edges;
    cvtColor( colorSmall, edges, CV_BGR2GRAY );
    //cv::blur( edges, edges, cv::Size(5,5) );
    //cv::Canny(edges, edges, 50, 50 * 5);
    //cv::blur( edges, edges, cv::Size(3,3) );
    cv::adaptiveThreshold(edges, edges, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 31, 10);
    //output(edges);
    //return;
    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(edges, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
    for (int i=0; i<contours.size(); i++) {
        cv::approxPolyDP(contours[i], contours[i], 6, true);
        if (contours[i].size() == 3) {
            cv::drawContours(colorSmall, contours, i, cv::Scalar(255, 0, 0));
        } else if (contours[i].size() == 4) {
            cv::drawContours(colorSmall, contours, i, cv::Scalar(0, 0, 255));
        }
    }
    output(colorSmall);
}

- (void)combTracer:(UIImage *)test result:(void(^)(UIImage *result))callback {
    test = [[Tracking new] resizeImage:test];
    cv::Mat color;
    UIImageToMat(test, color);
    cv::Mat gray;
    cv::Mat edges;
    cvtColor( color, edges, CV_BGR2GRAY );
    //cv::blur(edges, edges, cv::Size(2,2));
    cv::adaptiveThreshold(edges, edges, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, [[Tracking new] thresholdRadius], 10);
    //output(edges);
    //return;
    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(edges, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
    for (int i=0; i<contours.size(); i++) {
        cv::approxPolyDP(contours[i], contours[i], cv::arcLength(contours[i], true) * 0.007, true);
        cv::drawContours(color, contours, i, cv::Scalar(255, 0, 0));
    }
    output(color);
}

- (void)generousTriangleFinder:(UIImage *)test result:(void(^)(UIImage *result))callback {
    CGFloat maxDimension = 600;
    CGFloat scale = MIN(maxDimension / test.size.width, maxDimension / test.size.height);
    cv::Mat color;
    UIImageToMat(test, color);
    cv::Mat colorSmall;
    cv::resize(color, colorSmall, cv::Size(test.size.width * scale, test.size.height * scale));
    cv::Mat gray;
    cvtColor( colorSmall, gray, CV_BGR2GRAY );
    cv::Mat edges;
    cv::blur( gray, edges, cv::Size(3,3) );
    //cv::Canny(edges, edges, 50, 50 * 5);
    cv::adaptiveThreshold(edges, edges, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 25, 0);
    //output(edges);
    //return;
    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(edges, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
    for (int i=0; i<contours.size(); i++) {
        cv::approxPolyDP(contours[i], contours[i], 20, true);
        if (contours[i].size() == 3) {
            cv::drawContours(colorSmall, contours, i, cv::Scalar(255, 0, 0));
        }
    }
    output(colorSmall);
}

- (void)houghpLineFinder:(UIImage *)test result:(void(^)(UIImage *result))callback {
    CGFloat maxDimension = 600;
    CGFloat scale = MIN(maxDimension / test.size.width, maxDimension / test.size.height);
    cv::Mat color;
    UIImageToMat(test, color);
    cv::Mat colorSmall;
    cv::resize(color, colorSmall, cv::Size(test.size.width * scale, test.size.height * scale));
    cv::Mat gray;
    cvtColor( colorSmall, gray, CV_BGR2GRAY );
    cv::Mat edges;
    cv::blur( gray, edges, cv::Size(3,3) );
    cv::Canny(edges, edges, 50, 50 * 5);
    std::vector<cv::Vec4i> lines;
    cv::HoughLinesP(edges, lines, 1, CV_PI/180, 20);
    for (int i=0; i<lines.size(); i++) {
        cv::line(colorSmall, cv::Point(lines[i][0], lines[i][1]), cv::Point(lines[i][2], lines[i][3]), cv::Scalar(255,0,0));
    }
    output(colorSmall);
}

- (NSString *)testDir {
    return @"/Users/nateparrott/Documents/SW/Instagrade2/ScantronKit/tests/comb tests";
}

- (NSString *)testOutputDir {
    return [[self testDir] stringByAppendingPathComponent:@"Outputs"];
}

- (NSArray *)testImages {
    NSMutableArray *testImages = [NSMutableArray new];
    NSString *dir = [self testDir];
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil]) {
        BOOL isDir;
        NSString *path = [dir stringByAppendingPathComponent:file];
        [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
        if (!isDir) {
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            if (image) {
                [testImages addObject:image];
            }
        }
    }
    return testImages;
}

@end
