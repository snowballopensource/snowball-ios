// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBParticipation.m instead.

#import "_SBParticipation.h"

const struct SBParticipationAttributes SBParticipationAttributes = {
};

const struct SBParticipationRelationships SBParticipationRelationships = {
	.reel = @"reel",
	.user = @"user",
};

const struct SBParticipationFetchedProperties SBParticipationFetchedProperties = {
};

@implementation SBParticipationID
@end

@implementation _SBParticipation

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Participation" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Participation";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Participation" inManagedObjectContext:moc_];
}

- (SBParticipationID*)objectID {
	return (SBParticipationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic reel;

	

@dynamic user;

	






@end
