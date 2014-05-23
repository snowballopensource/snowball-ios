// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBClip.m instead.

#import "_SBClip.h"

const struct SBClipAttributes SBClipAttributes = {
	.createdAt = @"createdAt",
	.liked = @"liked",
	.likesCount = @"likesCount",
	.posterURL = @"posterURL",
	.remoteID = @"remoteID",
	.videoURL = @"videoURL",
};

const struct SBClipRelationships SBClipRelationships = {
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
	
	if ([key isEqualToString:@"likedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"liked"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"likesCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"likesCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic createdAt;






@dynamic liked;



- (BOOL)likedValue {
	NSNumber *result = [self liked];
	return [result boolValue];
}

- (void)setLikedValue:(BOOL)value_ {
	[self setLiked:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveLikedValue {
	NSNumber *result = [self primitiveLiked];
	return [result boolValue];
}

- (void)setPrimitiveLikedValue:(BOOL)value_ {
	[self setPrimitiveLiked:[NSNumber numberWithBool:value_]];
}





@dynamic likesCount;



- (int32_t)likesCountValue {
	NSNumber *result = [self likesCount];
	return [result intValue];
}

- (void)setLikesCountValue:(int32_t)value_ {
	[self setLikesCount:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveLikesCountValue {
	NSNumber *result = [self primitiveLikesCount];
	return [result intValue];
}

- (void)setPrimitiveLikesCountValue:(int32_t)value_ {
	[self setPrimitiveLikesCount:[NSNumber numberWithInt:value_]];
}





@dynamic posterURL;






@dynamic remoteID;






@dynamic videoURL;






@dynamic reel;

	

@dynamic user;

	






@end
