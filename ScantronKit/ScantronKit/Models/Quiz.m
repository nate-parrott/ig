#import "Quiz.h"

@interface Quiz ()

// Private interface goes here.

@end

@implementation Quiz

- (NSInteger)totalPages {
    NSInteger totalPages = 1;
    for (NSDictionary *item in [self.json valueForKey:@"items"]) {
        if (item[@"frame"]) {
            NSInteger pageNum = [[item[@"frame"] firstObject] integerValue];
            totalPages = MAX(pageNum + 1, totalPages);
        }
    }
    return totalPages;
}

@end
