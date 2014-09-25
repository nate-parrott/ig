//
//  UIImage+PixelData.m
//  ScantronKit
//
//  Created by Nate Parrott on 9/16/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "UIImage+PixelData.h"
#import <Accelerate/Accelerate.h>

@interface ImagePixelData () {
    double _bluriness;
}

@end

@implementation ImagePixelData

- (void)dealloc {
    free(self.bytes);
}

- (float)brightnessAtX:(NSInteger)x y:(NSInteger)y {
    UInt8 *pixel = self.bytes + y * self.width + x;
    return pixel[0] + pixel[1] + pixel[2] / (255.0 * 3);
}

- (double)averageBrightnessInRect:(CGRect)rect {
    UInt8 *bytes = self.bytes;
    NSUInteger width = self.width;
    NSInteger x1 = rect.origin.x;
    NSInteger y1 = rect.origin.y;
    NSInteger x2 = x1 + rect.size.width;
    NSInteger y2 = y1 + rect.size.height;
    double sum = 0;
    for (NSInteger x=x1; x<x2; x++) {
        for (NSInteger y=y1; y<y2; y++) {
            UInt8 *pixel = bytes + 4 * (y * width + x);
            // 0.21 R + 0.72 G + 0.07 B
            sum += pixel[0] * 0.21/255.0 + pixel[1] * 0.72/255.0 + pixel[2] * 0.07/255.0;
        }
    }
    return sum / ((x2-x1) * (y2-y1));
}

- (double)blurrinessMetric {
    if (_bluriness) return _bluriness;
    double totalBluriness = 0;
    NSInteger width = self.width;
    NSInteger height = self.height;
    UInt8 *bytes = self.bytes;
    for (NSInteger row=0; row < height; row++) {
        UInt8 *rowBytes = bytes + 4 * (row * width);
        double colBlur = 0;
        for (NSInteger col=0; col < width - 1; col++) {
            UInt8 byte1 = rowBytes[col];
            UInt8 byte2 = rowBytes[row];
            colBlur += pow(byte1 / 255.0 - byte2 / 255.0, 2);
        }
        totalBluriness += colBlur / width;
    }
    _bluriness = - totalBluriness / height;
    return _bluriness;
}

- (double)fastBlurrinessMetric {
    vImage_Buffer buffer;
    buffer.width = self.width;
    buffer.height = self.height;
    buffer.rowBytes = buffer.width * 4;
    buffer.data = self.bytes;
    
    vImage_Buffer convolved;
    convolved.width = buffer.width;
    convolved.height = buffer.height;
    convolved.rowBytes = buffer.rowBytes;
    convolved.data = malloc(4 * convolved.rowBytes * convolved.height);
    
    int16_t kernel[9] = {
        -1, -1, -1
        -1, 0, -1,
        1, 1, 1
    };
    vImageConvolveWithBias_ARGB8888(&buffer, &convolved, NULL, 0, 0, kernel, 3, 3, 3, 127, nil, kvImageEdgeExtend);
    vImagePixelCount *pixelCounts = malloc(sizeof(vImagePixelCount) * 256 * 4);
    vImagePixelCount *histogramsForChannels[4] = {pixelCounts, pixelCounts + 256, pixelCounts + 512, pixelCounts + 768};
    vImageHistogramCalculation_ARGB8888(&convolved, histogramsForChannels, 0);
    double bluriness = 0;
    for (int i=0; i<256; i++) {
        bluriness += histogramsForChannels[1][i] * (256 - i) / 256.0;
    }
    free(pixelCounts);
    free(convolved.data);
    
    return bluriness;
}

@end


@implementation UIImage (PixelData)

- (ImagePixelData *)pixelData {
    CGImageRef image = [self CGImage];
    NSUInteger width = CGImageGetWidth(image);
    NSUInteger height = CGImageGetHeight(image);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    ImagePixelData *d = [ImagePixelData new];
    d.bytes = rawData;//malloc(height * width * 4);
    //memcpy(d.bytes, rawData, height * width * 4);
    d.width = width;
    d.height = height;
    CGContextRelease(context);
    return d;
}

@end

