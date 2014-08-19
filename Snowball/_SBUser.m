// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBUser.m instead.

#import "_SBUser.h"

const struct SBUserAttributes SBUserAttributes = {
	.avatarURL = @"avatarURL",
	.bio = @"bio",
	.color = @"color",
	.email = @"email",
	.following = @"following",
	.isCurrentUser = @"isCurrentUser",
	.name = @"name",
	.phoneNumber = @"phoneNumber",
	.remoteID = @"remoteID",
	.username = @"username",
};

const struct SBUserRelationships SBUserRelationships = {
	.clips = @"clips",
	.participations = @"participations",
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
	
	if ([key isEqualToString:@"followingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"following"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isCurrentUserValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isCurrentUser"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic avatarURL;






@dynamic bio;






@dynamic color;






@dynamic email;






@dynamic following;



- (BOOL)followingValue {
	NSNumber *result = [self following];
	return [result boolValue];
}

- (void)setFollowingValue:(BOOL)value_ {
	[self setFollowing:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFollowingValue {
	NSNumber *result = [self primitiveFollowing];
	return [result boolValue];
}

- (void)setPrimitiveFollowingValue:(BOOL)value_ {
	[self setPrimitiveFollowing:[NSNumber numberWithBool:value_]];
}





@dynamic isCurrentUser;



- (BOOL)isCurrentUserValue {
	NSNumber *result = [self isCurrentUser];
	return [result boolValue];
}

- (void)setIsCurrentUserValue:(BOOL)value_ {
	[self setIsCurrentUser:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsCurrentUserValue {
	NSNumber *result = [self primitiveIsCurrentUser];
	return [result boolValue];
}

- (void)setPrimitiveIsCurrentUserValue:(BOOL)value_ {
	[self setPrimitiveIsCurrentUser:[NSNumber numberWithBool:value_]];
}





@dynamic name;






@dynamic phoneNumber;






@dynamic remoteID;






@dynamic username;






@dynamic clips;

	
- (NSMutableSet*)clipsSet {
	[self willAccessValueForKey:@"clips"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"clips"];
  
	[self didAccessValueForKey:@"clips"];
	return result;
}
	

@dynamic participations;

	
- (NSMutableSet*)participationsSet {
	[self willAccessValueForKey:@"participations"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"participations"];
  
	[self didAccessValueForKey:@"participations"];
	return result;
}
	






@end
