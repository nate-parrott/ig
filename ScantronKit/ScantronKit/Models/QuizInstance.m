#import "QuizInstance.h"
#import "Quiz.h"
#import "PageImage.h"
#import <UIKit/UIKit.h>
#import "InstaGrade_Scanner-Swift.h"

@interface QuizInstance ()

// Private interface goes here.

@end

@implementation QuizInstance

// Custom logic goes here.

- (NSDictionary *)serialize {
    id nameImageData = [NSNull null];
    UIImage *nameImage = [self nameImage];
    if (nameImage) {
        nameImageData = UIImageJPEGRepresentation(nameImage, 0.3);
    }
    return @{
             @"earnedScore": self.earnedScore,
             @"maximumScore": self.maximumScore,
             @"responseItems": self.itemsWithResponses,
             @"quizIndex": self.quiz.index,
             @"timestamp": @(self.date.timeIntervalSinceReferenceDate),
             @"nameImage": nameImageData
             };
}

@end
