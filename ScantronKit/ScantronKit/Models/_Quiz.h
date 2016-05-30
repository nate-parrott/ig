// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Quiz.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class QuizInstance;

@class NSObject;

@interface QuizID : NSManagedObjectID {}
@end

@interface _Quiz : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) QuizID *objectID;

@property (nonatomic, strong, nullable) NSDate* added;

@property (nonatomic, strong, nullable) NSNumber* index;

@property (atomic) int32_t indexValue;
- (int32_t)indexValue;
- (void)setIndexValue:(int32_t)value_;

@property (nonatomic, strong, nullable) id json;

@property (nonatomic, strong, nullable) NSString* title;

@property (nonatomic, strong, nullable) NSSet<QuizInstance*> *instances;
- (nullable NSMutableSet<QuizInstance*>*)instancesSet;

@end

@interface _Quiz (InstancesCoreDataGeneratedAccessors)
- (void)addInstances:(NSSet<QuizInstance*>*)value_;
- (void)removeInstances:(NSSet<QuizInstance*>*)value_;
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

- (NSMutableSet<QuizInstance*>*)primitiveInstances;
- (void)setPrimitiveInstances:(NSMutableSet<QuizInstance*>*)value;

@end

@interface QuizAttributes: NSObject 
+ (NSString *)added;
+ (NSString *)index;
+ (NSString *)json;
+ (NSString *)title;
@end

@interface QuizRelationships: NSObject
+ (NSString *)instances;
@end

NS_ASSUME_NONNULL_END
