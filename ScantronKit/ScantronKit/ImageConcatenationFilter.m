//
//  ImageConcatenationFilter.m
//  ScantronKit
//
//  Created by Nate Parrott on 9/18/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "ImageConcatenationFilter.h"

NSString *const kImageConcatenationFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform highp float split;
 
 void main()
 {
     highp vec2 topTexCoordinate = textureCoordinate * vec2(1.0, 1.0 / split);
     highp vec2 bottomTexCoordinate = (textureCoordinate2 - vec2(0.0, split)) * vec2(1.0, 1.0 / (1.0 - split));
     if (topTexCoordinate.y <= 1.0) {
         gl_FragColor = texture2D(inputImageTexture, topTexCoordinate);
     } else {
         gl_FragColor = texture2D(inputImageTexture2, bottomTexCoordinate);
     }
 }
 );


@implementation ImageConcatenationFilter

- (id)initWithFractionSplit:(CGFloat)split {
    self = [super initWithFragmentShaderFromString:kImageConcatenationFragmentShaderString];
    [self setFloat:split forUniformName:@"split"];
    return self;
}

@end
