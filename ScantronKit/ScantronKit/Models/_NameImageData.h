// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to NameImageData.h instead.

#import <CoreData/CoreData.h>

extern const struct NameImageDataAttributes {
	__unsafe_unretained NSString *data;
} NameImageDataAttributes;

extern const struct NameImageDataRelationships {
	__unsafe_unretained NSString *instance;
} NameImageDataRelationships;

@class QuizInstance;

@interface NameImageDataID : NSManagedObjectID {}
@end

@interface _NameImageData : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) NameImageDataID* objectID;

@property (nonatomic, strong) NSData* data;

//- (BOOL)validateData:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) QuizInstance *instance;

//- (BOOL)validateInstance:(id*)value_ error:(NSError**)error_;

@end

@interface _NameImageData (CoreDataGeneratedPrimitiveAccessors)

- (NSData*)primitiveData;
- (void)setPrimitiveData:(NSData*)value;

- (QuizInstance*)primitiveInstance;
- (void)setPrimitiveInstance:(QuizInstance*)value;

@end
