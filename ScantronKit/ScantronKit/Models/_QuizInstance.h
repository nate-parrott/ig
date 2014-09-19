// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to QuizInstance.h instead.

#import <CoreData/CoreData.h>

extern const struct QuizInstanceAttributes {
	__unsafe_unretained NSString *itemResponses;
} QuizInstanceAttributes;

extern const struct QuizInstanceRelationships {
	__unsafe_unretained NSString *quiz;
} QuizInstanceRelationships;

@class Quiz;

@class NSObject;

@interface QuizInstanceID : NSManagedObjectID {}
@end

@interface _QuizInstance : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) QuizInstanceID* objectID;

@property (nonatomic, strong) id itemResponses;

//- (BOOL)validateItemResponses:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Quiz *quiz;

//- (BOOL)validateQuiz:(id*)value_ error:(NSError**)error_;

@end

@interface _QuizInstance (CoreDataGeneratedPrimitiveAccessors)

- (id)primitiveItemResponses;
- (void)setPrimitiveItemResponses:(id)value;

- (Quiz*)primitiveQuiz;
- (void)setPrimitiveQuiz:(Quiz*)value;

@end
