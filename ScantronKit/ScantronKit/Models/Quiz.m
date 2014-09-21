#import "Quiz.h"

@interface Quiz ()

// Private interface goes here.

@end

@implementation Quiz

- (NSInteger)totalPages {
    return [self.json[@"pageCount"] integerValue];
}

@end
