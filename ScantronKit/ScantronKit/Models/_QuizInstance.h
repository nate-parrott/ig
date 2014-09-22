// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to QuizInstance.h instead.

#import <CoreData/CoreData.h>

extern const struct QuizInstanceAttributes {
	__unsafe_unretained NSString *itemsWithResponses;
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

@property (nonatomic, strong) id itemsWithResponses;

//- (BOOL)validateItemsWithResponses:(id*)value_ error:(NSError**)error_;

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

- (id)primitiveItemsWithResponses;
- (void)setPrimitiveItemsWithResponses:(id)value;

- (NSMutableOrderedSet*)primitivePageImages;
- (void)setPrimitivePageImages:(NSMutableOrderedSet*)value;

- (Quiz*)primitiveQuiz;
- (void)setPrimitiveQuiz:(Quiz*)value;

@end
