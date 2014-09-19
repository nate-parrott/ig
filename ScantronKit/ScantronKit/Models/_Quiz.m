// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Quiz.m instead.

#import "_Quiz.h"

const struct QuizAttributes QuizAttributes = {
	.added = @"added",
	.index = @"index",
	.json = @"json",
	.title = @"title",
};

const struct QuizRelationships QuizRelationships = {
	.instances = @"instances",
};

@implementation QuizID
@end

@implementation _Quiz

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Quiz" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Quiz";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Quiz" inManagedObjectContext:moc_];
}

- (QuizID*)objectID {
	return (QuizID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"indexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"index"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic added;

@dynamic index;

- (int32_t)indexValue {
	NSNumber *result = [self index];
	return [result intValue];
}

- (void)setIndexValue:(int32_t)value_ {
	[self setIndex:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveIndexValue {
	NSNumber *result = [self primitiveIndex];
	return [result intValue];
}

- (void)setPrimitiveIndexValue:(int32_t)value_ {
	[self setPrimitiveIndex:[NSNumber numberWithInt:value_]];
}

@dynamic json;

@dynamic title;

@dynamic instances;

- (NSMutableSet*)instancesSet {
	[self willAccessValueForKey:@"instances"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"instances"];

	[self didAccessValueForKey:@"instances"];
	return result;
}

@end

