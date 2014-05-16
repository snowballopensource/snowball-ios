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
	
	if ([key isEqualToString:@"createdAtValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"createdAt"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic createdAt;



- (int32_t)createdAtValue {
	NSNumber *result = [self createdAt];
	return [result intValue];
}

- (void)setCreatedAtValue:(int32_t)value_ {
	[self setCreatedAt:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveCreatedAtValue {
	NSNumber *result = [self primitiveCreatedAt];
	return [result intValue];
}

- (void)setPrimitiveCreatedAtValue:(int32_t)value_ {
	[self setPrimitiveCreatedAt:[NSNumber numberWithInt:value_]];
}





@dynamic posterURL;






@dynamic remoteID;






@dynamic videoURL;






@dynamic reel;

	

@dynamic user;

	






@end
