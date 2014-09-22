// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PageImage.h instead.

#import <CoreData/CoreData.h>

extern const struct PageImageAttributes {
	__unsafe_unretained NSString *data;
} PageImageAttributes;

extern const struct PageImageRelationships {
	__unsafe_unretained NSString *quizInstance;
} PageImageRelationships;

@class QuizInstance;

@interface PageImageID : NSManagedObjectID {}
@end

@interface _PageImage : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) PageImageID* objectID;

@property (nonatomic, strong) NSData* data;

//- (BOOL)validateData:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) QuizInstance *quizInstance;

//- (BOOL)validateQuizInstance:(id*)value_ error:(NSError**)error_;

@end

@interface _PageImage (CoreDataGeneratedPrimitiveAccessors)

- (NSData*)primitiveData;
- (void)setPrimitiveData:(NSData*)value;

- (QuizInstance*)primitiveQuizInstance;
- (void)setPrimitiveQuizInstance:(QuizInstance*)value;

@end
