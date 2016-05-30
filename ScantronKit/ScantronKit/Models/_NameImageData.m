// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to NameImageData.m instead.

#import "_NameImageData.h"

@implementation NameImageDataID
@end

@implementation _NameImageData

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"NameImageData" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"NameImageData";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"NameImageData" inManagedObjectContext:moc_];
}

- (NameImageDataID*)objectID {
	return (NameImageDataID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic data;

@dynamic instance;

@end

@implementation NameImageDataAttributes 
+ (NSString *)data {
	return @"data";
}
@end

@implementation NameImageDataRelationships 
+ (NSString *)instance {
	return @"instance";
}
@end

