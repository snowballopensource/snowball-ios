// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBUser.m instead.

#import "_SBUser.h"

const struct SBUserAttributes SBUserAttributes = {
	.email = @"email",
	.remoteID = @"remoteID",
	.username = @"username",
};

const struct SBUserRelationships SBUserRelationships = {
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
	

	return keyPaths;
}




@dynamic email;






@dynamic remoteID;






@dynamic username;











@end
