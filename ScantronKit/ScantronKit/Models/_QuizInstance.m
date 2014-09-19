// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to QuizInstance.m instead.

#import "_QuizInstance.h"

const struct QuizInstanceAttributes QuizInstanceAttributes = {
	.itemResponses = @"itemResponses",
};

const struct QuizInstanceRelationships QuizInstanceRelationships = {
	.quiz = @"quiz",
};

@implementation QuizInstanceID
@end

@implementation _QuizInstance

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"QuizInstance" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"QuizInstance";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"QuizInstance" inManagedObjectContext:moc_];
}

- (QuizInstanceID*)objectID {
	return (QuizInstanceID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic itemResponses;

@dynamic quiz;

@end

