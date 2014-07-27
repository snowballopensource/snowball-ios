// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBClip.m instead.

#import "_SBClip.h"

const struct SBClipAttributes SBClipAttributes = {
	.createdAt = @"createdAt",
	.posterURL = @"posterURL",
	.remoteID = @"remoteID",
	.videoURL = @"videoURL",
};

const struct SBClipRelationships SBClipRelationships = {
	.lastWatchedForReel = @"lastWatchedForReel",
	.reel = @"reel",
	.user = @"user",
};

const struct SBClipFetchedProperties SBClipFetchedProperties = {
};

@implementation SBClipID
@end

@implementation _SBClip

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Clip" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Clip";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Clip" inManagedObjectContext:moc_];
}

- (SBClipID*)objectID {
	return (SBClipID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic createdAt;






@dynamic posterURL;






@dynamic remoteID;






@dynamic videoURL;






@dynamic lastWatchedForReel;

	

@dynamic reel;

	

@dynamic user;

	






@end
