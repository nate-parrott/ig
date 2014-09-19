//
//  ImageConcatenationFilter.h
//  ScantronKit
//
//  Created by Nate Parrott on 9/18/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@interface ImageConcatenationFilter : GPUImageTwoInputFilter

- (id)initWithFractionSplit:(CGFloat)split; // 0.5 = even split; 0.25 = compress the top image into 25% of image, etc

@end
