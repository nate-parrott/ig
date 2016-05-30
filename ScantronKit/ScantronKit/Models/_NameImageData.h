// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to NameImageData.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class QuizInstance;

@interface NameImageDataID : NSManagedObjectID {}
@end

@interface _NameImageData : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) NameImageDataID *objectID;

@property (nonatomic, strong, nullable) NSData* data;

@property (nonatomic, strong, nullable) QuizInstance *instance;

@end

@interface _NameImageData (CoreDataGeneratedPrimitiveAccessors)

- (NSData*)primitiveData;
- (void)setPrimitiveData:(NSData*)value;

- (QuizInstance*)primitiveInstance;
- (void)setPrimitiveInstance:(QuizInstance*)value;

@end

@interface NameImageDataAttributes: NSObject 
+ (NSString *)data;
@end

@interface NameImageDataRelationships: NSObject
+ (NSString *)instance;
@end

NS_ASSUME_NONNULL_END
