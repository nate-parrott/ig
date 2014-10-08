#import "QuizInstance.h"
#import "Quiz.h"
#import "PageImage.h"
#import <UIKit/UIKit.h>
#import "InstaGrade_Scanner-Swift.h"
#import "NameImageData.h"

@interface QuizInstance ()

// Private interface goes here.

@end

@implementation QuizInstance

// Custom logic goes here.

- (NSDictionary *)serialize {
    id nameImageData = [NSNull null];
    if (self.nameImageData) {
        nameImageData = self.nameImageData.data;
    } else {
        UIImage *nameImage = [self nameImage];
        if (nameImage) {
            nameImageData = UIImageJPEGRepresentation(nameImage, 0.3);
        }
    }
    return @{
             @"uuid": self.uuid,
             @"earnedScore": self.earnedScore,
             @"maximumScore": self.maximumScore,
             @"responseItems": self.itemsWithResponses,
             @"quizIndex": self.quiz.index,
             @"timestamp": @(self.date.timeIntervalSince1970),
             @"nameImage": nameImageData
             };
}

- (UIImage *)nameImage {
    if (!self.nameImageData) {
        self.nameImageData = (id)[[[CoreDataManager new] getShared] newEntity:@"NameImageData"];
        self.nameImageData.data = UIImageJPEGRepresentation([self extractNameImage], 0.3);
        return [UIImage imageWithData:self.nameImageData.data];
    }
    return [UIImage imageWithData:self.nameImageData.data];
}

@end
