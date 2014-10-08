// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to NameImageData.m instead.

#import "_NameImageData.h"

const struct NameImageDataAttributes NameImageDataAttributes = {
	.data = @"data",
};

const struct NameImageDataRelationships NameImageDataRelationships = {
	.instance = @"instance",
};

@implementation NameImageDataID
@end

@implementation _NameImageData

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
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

