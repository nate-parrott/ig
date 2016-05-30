// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to QuizInstance.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class NameImageData;
@class PageImage;
@class Quiz;

@class NSObject;

@interface QuizInstanceID : NSManagedObjectID {}
@end

@interface _QuizInstance : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) QuizInstanceID *objectID;

@property (nonatomic, strong, nullable) NSDate* date;

@property (nonatomic, strong, nullable) NSNumber* earnedScore;

@property (atomic) double earnedScoreValue;
- (double)earnedScoreValue;
- (void)setEarnedScoreValue:(double)value_;

@property (nonatomic, strong, nullable) id itemsWithResponses;

@property (nonatomic, strong, nullable) NSNumber* maximumScore;

@property (atomic) double maximumScoreValue;
- (double)maximumScoreValue;
- (void)setMaximumScoreValue:(double)value_;

@property (nonatomic, strong, nullable) NSNumber* uploaded;

@property (atomic) BOOL uploadedValue;
- (BOOL)uploadedValue;
- (void)setUploadedValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSString* uploadedInBatch;

@property (nonatomic, strong, nullable) NSString* uuid;

@property (nonatomic, strong, nullable) NameImageData *nameImageData;

@property (nonatomic, strong, nullable) NSOrderedSet<PageImage*> *pageImages;
- (nullable NSMutableOrderedSet<PageImage*>*)pageImagesSet;

@property (nonatomic, strong, nullable) Quiz *quiz;

@end

@interface _QuizInstance (PageImagesCoreDataGeneratedAccessors)
- (void)addPageImages:(NSOrderedSet<PageImage*>*)value_;
- (void)removePageImages:(NSOrderedSet<PageImage*>*)value_;
- (void)addPageImagesObject:(PageImage*)value_;
- (void)removePageImagesObject:(PageImage*)value_;

- (void)insertObject:(PageImage*)value inPageImagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPageImagesAtIndex:(NSUInteger)idx;
- (void)insertPageImages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePageImagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPageImagesAtIndex:(NSUInteger)idx withObject:(PageImage*)value;
- (void)replacePageImagesAtIndexes:(NSIndexSet *)indexes withPageImages:(NSArray *)values;

@end

@interface _QuizInstance (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;

- (NSNumber*)primitiveEarnedScore;
- (void)setPrimitiveEarnedScore:(NSNumber*)value;

- (double)primitiveEarnedScoreValue;
- (void)setPrimitiveEarnedScoreValue:(double)value_;

- (id)primitiveItemsWithResponses;
- (void)setPrimitiveItemsWithResponses:(id)value;

- (NSNumber*)primitiveMaximumScore;
- (void)setPrimitiveMaximumScore:(NSNumber*)value;

- (double)primitiveMaximumScoreValue;
- (void)setPrimitiveMaximumScoreValue:(double)value_;

- (NSNumber*)primitiveUploaded;
- (void)setPrimitiveUploaded:(NSNumber*)value;

- (BOOL)primitiveUploadedValue;
- (void)setPrimitiveUploadedValue:(BOOL)value_;

- (NSString*)primitiveUploadedInBatch;
- (void)setPrimitiveUploadedInBatch:(NSString*)value;

- (NSString*)primitiveUuid;
- (void)setPrimitiveUuid:(NSString*)value;

- (NameImageData*)primitiveNameImageData;
- (void)setPrimitiveNameImageData:(NameImageData*)value;

- (NSMutableOrderedSet<PageImage*>*)primitivePageImages;
- (void)setPrimitivePageImages:(NSMutableOrderedSet<PageImage*>*)value;

- (Quiz*)primitiveQuiz;
- (void)setPrimitiveQuiz:(Quiz*)value;

@end

@interface QuizInstanceAttributes: NSObject 
+ (NSString *)date;
+ (NSString *)earnedScore;
+ (NSString *)itemsWithResponses;
+ (NSString *)maximumScore;
+ (NSString *)uploaded;
+ (NSString *)uploadedInBatch;
+ (NSString *)uuid;
@end

@interface QuizInstanceRelationships: NSObject
+ (NSString *)nameImageData;
+ (NSString *)pageImages;
+ (NSString *)quiz;
@end

NS_ASSUME_NONNULL_END
