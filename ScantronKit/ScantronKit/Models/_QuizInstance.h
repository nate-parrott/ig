// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to QuizInstance.h instead.

#import <CoreData/CoreData.h>

extern const struct QuizInstanceAttributes {
	__unsafe_unretained NSString *date;
	__unsafe_unretained NSString *earnedScore;
	__unsafe_unretained NSString *itemsWithResponses;
	__unsafe_unretained NSString *maximumScore;
	__unsafe_unretained NSString *uploaded;
	__unsafe_unretained NSString *uploadedInBatch;
	__unsafe_unretained NSString *uuid;
} QuizInstanceAttributes;

extern const struct QuizInstanceRelationships {
	__unsafe_unretained NSString *pageImages;
	__unsafe_unretained NSString *quiz;
} QuizInstanceRelationships;

@class PageImage;
@class Quiz;

@class NSObject;

@interface QuizInstanceID : NSManagedObjectID {}
@end

@interface _QuizInstance : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) QuizInstanceID* objectID;

@property (nonatomic, strong) NSDate* date;

//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* earnedScore;

@property (atomic) double earnedScoreValue;
- (double)earnedScoreValue;
- (void)setEarnedScoreValue:(double)value_;

//- (BOOL)validateEarnedScore:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id itemsWithResponses;

//- (BOOL)validateItemsWithResponses:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* maximumScore;

@property (atomic) double maximumScoreValue;
- (double)maximumScoreValue;
- (void)setMaximumScoreValue:(double)value_;

//- (BOOL)validateMaximumScore:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* uploaded;

@property (atomic) BOOL uploadedValue;
- (BOOL)uploadedValue;
- (void)setUploadedValue:(BOOL)value_;

//- (BOOL)validateUploaded:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* uploadedInBatch;

//- (BOOL)validateUploadedInBatch:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* uuid;

//- (BOOL)validateUuid:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSOrderedSet *pageImages;

- (NSMutableOrderedSet*)pageImagesSet;

@property (nonatomic, strong) Quiz *quiz;

//- (BOOL)validateQuiz:(id*)value_ error:(NSError**)error_;

@end

@interface _QuizInstance (PageImagesCoreDataGeneratedAccessors)
- (void)addPageImages:(NSOrderedSet*)value_;
- (void)removePageImages:(NSOrderedSet*)value_;
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

- (NSMutableOrderedSet*)primitivePageImages;
- (void)setPrimitivePageImages:(NSMutableOrderedSet*)value;

- (Quiz*)primitiveQuiz;
- (void)setPrimitiveQuiz:(Quiz*)value;

@end
