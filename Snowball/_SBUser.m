// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBUser.m instead.

#import "_SBUser.h"

const struct SBUserAttributes SBUserAttributes = {
	.clipsCount = @"clipsCount",
	.email = @"email",
	.followersCount = @"followersCount",
	.likesCount = @"likesCount",
	.remoteID = @"remoteID",
	.username = @"username",
};

const struct SBUserRelationships SBUserRelationships = {
	.clips = @"clips",
};

const struct SBUserFetchedProperties SBUserFetchedProperties = {
};

@implementation SBUserID
@end

@implementation _SBUser

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"User";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc_];
}

- (SBUserID*)objectID {
	return (SBUserID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"clipsCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"clipsCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"followersCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"followersCount"];
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




@dynamic clipsCount;



- (int32_t)clipsCountValue {
	NSNumber *result = [self clipsCount];
	return [result intValue];
}

- (void)setClipsCountValue:(int32_t)value_ {
	[self setClipsCount:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveClipsCountValue {
	NSNumber *result = [self primitiveClipsCount];
	return [result intValue];
}

- (void)setPrimitiveClipsCountValue:(int32_t)value_ {
	[self setPrimitiveClipsCount:[NSNumber numberWithInt:value_]];
}





@dynamic email;






@dynamic followersCount;



- (int32_t)followersCountValue {
	NSNumber *result = [self followersCount];
	return [result intValue];
}

- (void)setFollowersCountValue:(int32_t)value_ {
	[self setFollowersCount:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveFollowersCountValue {
	NSNumber *result = [self primitiveFollowersCount];
	return [result intValue];
}

- (void)setPrimitiveFollowersCountValue:(int32_t)value_ {
	[self setPrimitiveFollowersCount:[NSNumber numberWithInt:value_]];
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





@dynamic remoteID;






@dynamic username;






@dynamic clips;

	
- (NSMutableSet*)clipsSet {
	[self willAccessValueForKey:@"clips"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"clips"];
  
	[self didAccessValueForKey:@"clips"];
	return result;
}
	






@end
