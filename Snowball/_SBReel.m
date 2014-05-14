// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBReel.m instead.

#import "_SBReel.h"

const struct SBReelAttributes SBReelAttributes = {
	.name = @"name",
	.remoteID = @"remoteID",
};

const struct SBReelRelationships SBReelRelationships = {
	.clips = @"clips",
};

const struct SBReelFetchedProperties SBReelFetchedProperties = {
};

@implementation SBReelID
@end

@implementation _SBReel

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Reel" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Reel";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Reel" inManagedObjectContext:moc_];
}

- (SBReelID*)objectID {
	return (SBReelID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic remoteID;






@dynamic clips;

	
- (NSMutableSet*)clipsSet {
	[self willAccessValueForKey:@"clips"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"clips"];
  
	[self didAccessValueForKey:@"clips"];
	return result;
}
	






@end
