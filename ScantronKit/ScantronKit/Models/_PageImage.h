// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PageImage.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class QuizInstance;

@interface PageImageID : NSManagedObjectID {}
@end

@interface _PageImage : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) PageImageID *objectID;

@property (nonatomic, strong, nullable) NSData* data;

@property (nonatomic, strong, nullable) QuizInstance *quizInstance;

@end

@interface _PageImage (CoreDataGeneratedPrimitiveAccessors)

- (NSData*)primitiveData;
- (void)setPrimitiveData:(NSData*)value;

- (QuizInstance*)primitiveQuizInstance;
- (void)setPrimitiveQuizInstance:(QuizInstance*)value;

@end

@interface PageImageAttributes: NSObject 
+ (NSString *)data;
@end

@interface PageImageRelationships: NSObject
+ (NSString *)quizInstance;
@end

NS_ASSUME_NONNULL_END
