// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBUser.h instead.

#import <CoreData/CoreData.h>
#import "SBManagedObject.h"

extern const struct SBUserAttributes {
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *remoteID;
	__unsafe_unretained NSString *username;
} SBUserAttributes;

extern const struct SBUserRelationships {
	__unsafe_unretained NSString *clips;
} SBUserRelationships;

extern const struct SBUserFetchedProperties {
} SBUserFetchedProperties;

@class SBClip;





@interface SBUserID : NSManagedObjectID {}
@end

@interface _SBUser : SBManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SBUserID*)objectID;





@property (nonatomic, strong) NSString* email;



//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* remoteID;



//- (BOOL)validateRemoteID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* username;



//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *clips;

- (NSMutableSet*)clipsSet;





@end

@interface _SBUser (CoreDataGeneratedAccessors)

- (void)addClips:(NSSet*)value_;
- (void)removeClips:(NSSet*)value_;
- (void)addClipsObject:(SBClip*)value_;
- (void)removeClipsObject:(SBClip*)value_;

@end

@interface _SBUser (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSString*)primitiveRemoteID;
- (void)setPrimitiveRemoteID:(NSString*)value;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;





- (NSMutableSet*)primitiveClips;
- (void)setPrimitiveClips:(NSMutableSet*)value;


@end
