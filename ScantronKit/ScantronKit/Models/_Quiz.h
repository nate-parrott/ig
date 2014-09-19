// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Quiz.h instead.

#import <CoreData/CoreData.h>

extern const struct QuizAttributes {
	__unsafe_unretained NSString *added;
	__unsafe_unretained NSString *index;
	__unsafe_unretained NSString *json;
	__unsafe_unretained NSString *title;
} QuizAttributes;

extern const struct QuizRelationships {
	__unsafe_unretained NSString *instances;
} QuizRelationships;

@class QuizInstance;

@class NSObject;

@interface QuizID : NSManagedObjectID {}
@end

@interface _Quiz : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) QuizID* objectID;

@property (nonatomic, strong) NSDate* added;

//- (BOOL)validateAdded:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* index;

@property (atomic) int32_t indexValue;
- (int32_t)indexValue;
- (void)setIndexValue:(int32_t)value_;

//- (BOOL)validateIndex:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id json;

//- (BOOL)validateJson:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* title;

//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *instances;

- (NSMutableSet*)instancesSet;

@end

@interface _Quiz (InstancesCoreDataGeneratedAccessors)
- (void)addInstances:(NSSet*)value_;
- (void)removeInstances:(NSSet*)value_;
- (void)addInstancesObject:(QuizInstance*)value_;
- (void)removeInstancesObject:(QuizInstance*)value_;

@end

@interface _Quiz (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveAdded;
- (void)setPrimitiveAdded:(NSDate*)value;

- (NSNumber*)primitiveIndex;
- (void)setPrimitiveIndex:(NSNumber*)value;

- (int32_t)primitiveIndexValue;
- (void)setPrimitiveIndexValue:(int32_t)value_;

- (id)primitiveJson;
- (void)setPrimitiveJson:(id)value;

- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;

- (NSMutableSet*)primitiveInstances;
- (void)setPrimitiveInstances:(NSMutableSet*)value;

@end
