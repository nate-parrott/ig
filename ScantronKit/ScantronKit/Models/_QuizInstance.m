// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to QuizInstance.m instead.

#import "_QuizInstance.h"

@implementation QuizInstanceID
@end

@implementation _QuizInstance

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
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

	if ([key isEqualToString:@"earnedScoreValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"earnedScore"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"maximumScoreValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"maximumScore"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"uploadedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"uploaded"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic date;

@dynamic earnedScore;

- (double)earnedScoreValue {
	NSNumber *result = [self earnedScore];
	return [result doubleValue];
}

- (void)setEarnedScoreValue:(double)value_ {
	[self setEarnedScore:@(value_)];
}

- (double)primitiveEarnedScoreValue {
	NSNumber *result = [self primitiveEarnedScore];
	return [result doubleValue];
}

- (void)setPrimitiveEarnedScoreValue:(double)value_ {
	[self setPrimitiveEarnedScore:@(value_)];
}

@dynamic itemsWithResponses;

@dynamic maximumScore;

- (double)maximumScoreValue {
	NSNumber *result = [self maximumScore];
	return [result doubleValue];
}

- (void)setMaximumScoreValue:(double)value_ {
	[self setMaximumScore:@(value_)];
}

- (double)primitiveMaximumScoreValue {
	NSNumber *result = [self primitiveMaximumScore];
	return [result doubleValue];
}

- (void)setPrimitiveMaximumScoreValue:(double)value_ {
	[self setPrimitiveMaximumScore:@(value_)];
}

@dynamic uploaded;

- (BOOL)uploadedValue {
	NSNumber *result = [self uploaded];
	return [result boolValue];
}

- (void)setUploadedValue:(BOOL)value_ {
	[self setUploaded:@(value_)];
}

- (BOOL)primitiveUploadedValue {
	NSNumber *result = [self primitiveUploaded];
	return [result boolValue];
}

- (void)setPrimitiveUploadedValue:(BOOL)value_ {
	[self setPrimitiveUploaded:@(value_)];
}

@dynamic uploadedInBatch;

@dynamic uuid;

@dynamic nameImageData;

@dynamic pageImages;

- (NSMutableOrderedSet<PageImage*>*)pageImagesSet {
	[self willAccessValueForKey:@"pageImages"];

	NSMutableOrderedSet<PageImage*> *result = (NSMutableOrderedSet<PageImage*>*)[self mutableOrderedSetValueForKey:@"pageImages"];

	[self didAccessValueForKey:@"pageImages"];
	return result;
}

@dynamic quiz;

@end

@implementation _QuizInstance (PageImagesCoreDataGeneratedAccessors)
- (void)addPageImages:(NSOrderedSet<PageImage*>*)value_ {
	[self.pageImagesSet unionOrderedSet:value_];
}
- (void)removePageImages:(NSOrderedSet<PageImage*>*)value_ {
	[self.pageImagesSet minusOrderedSet:value_];
}
- (void)addPageImagesObject:(PageImage*)value_ {
	[self.pageImagesSet addObject:value_];
}
- (void)removePageImagesObject:(PageImage*)value_ {
	[self.pageImagesSet removeObject:value_];
}
- (void)insertObject:(PageImage*)value inPageImagesAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"pageImages"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self pageImages]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"pageImages"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"pageImages"];
}
- (void)removeObjectFromPageImagesAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"pageImages"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self pageImages]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"pageImages"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"pageImages"];
}
- (void)insertPageImages:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"pageImages"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self pageImages]];
    [tmpOrderedSet insertObjects:value atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"pageImages"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"pageImages"];
}
- (void)removePageImagesAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"pageImages"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self pageImages]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"pageImages"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"pageImages"];
}
- (void)replaceObjectInPageImagesAtIndex:(NSUInteger)idx withObject:(PageImage*)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"pageImages"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self pageImages]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"pageImages"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"pageImages"];
}
- (void)replacePageImagesAtIndexes:(NSIndexSet *)indexes withPageImages:(NSArray *)value {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"pageImages"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self pageImages]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"pageImages"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"pageImages"];
}
@end

@implementation QuizInstanceAttributes 
+ (NSString *)date {
	return @"date";
}
+ (NSString *)earnedScore {
	return @"earnedScore";
}
+ (NSString *)itemsWithResponses {
	return @"itemsWithResponses";
}
+ (NSString *)maximumScore {
	return @"maximumScore";
}
+ (NSString *)uploaded {
	return @"uploaded";
}
+ (NSString *)uploadedInBatch {
	return @"uploadedInBatch";
}
+ (NSString *)uuid {
	return @"uuid";
}
@end

@implementation QuizInstanceRelationships 
+ (NSString *)nameImageData {
	return @"nameImageData";
}
+ (NSString *)pageImages {
	return @"pageImages";
}
+ (NSString *)quiz {
	return @"quiz";
}
@end

