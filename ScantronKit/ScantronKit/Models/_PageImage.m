// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PageImage.m instead.

#import "_PageImage.h"

@implementation PageImageID
@end

@implementation _PageImage

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"PageImage" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"PageImage";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"PageImage" inManagedObjectContext:moc_];
}

- (PageImageID*)objectID {
	return (PageImageID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic data;

@dynamic quizInstance;

@end

@implementation PageImageAttributes 
+ (NSString *)data {
	return @"data";
}
@end

@implementation PageImageRelationships 
+ (NSString *)quizInstance {
	return @"quizInstance";
}
@end

