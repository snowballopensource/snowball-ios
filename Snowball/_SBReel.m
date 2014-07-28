// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBReel.m instead.

#import "_SBReel.h"

const struct SBReelAttributes SBReelAttributes = {
	.homeFeedSession = @"homeFeedSession",
	.lastClipCreatedAt = @"lastClipCreatedAt",
	.name = @"name",
	.recentParticipantsNames = @"recentParticipantsNames",
	.remoteID = @"remoteID",
};

const struct SBReelRelationships SBReelRelationships = {
	.clips = @"clips",
	.lastWatchedClip = @"lastWatchedClip",
	.participants = @"participants",
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




@dynamic homeFeedSession;






@dynamic lastClipCreatedAt;






@dynamic name;






@dynamic recentParticipantsNames;






@dynamic remoteID;






@dynamic clips;

	
- (NSMutableSet*)clipsSet {
	[self willAccessValueForKey:@"clips"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"clips"];
  
	[self didAccessValueForKey:@"clips"];
	return result;
}
	

@dynamic lastWatchedClip;

	

@dynamic participants;

	
- (NSMutableSet*)participantsSet {
	[self willAccessValueForKey:@"participants"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"participants"];
  
	[self didAccessValueForKey:@"participants"];
	return result;
}
	






@end
