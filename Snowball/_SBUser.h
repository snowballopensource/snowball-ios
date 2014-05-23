// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBUser.h instead.

#import <CoreData/CoreData.h>
#import "SBManagedObject.h"

extern const struct SBUserAttributes {
	__unsafe_unretained NSString *clipsCount;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *followersCount;
	__unsafe_unretained NSString *likesCount;
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





@property (nonatomic, strong) NSNumber* clipsCount;



@property int32_t clipsCountValue;
- (int32_t)clipsCountValue;
- (void)setClipsCountValue:(int32_t)value_;

//- (BOOL)validateClipsCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* email;



//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* followersCount;



@property int32_t followersCountValue;
- (int32_t)followersCountValue;
- (void)setFollowersCountValue:(int32_t)value_;

//- (BOOL)validateFollowersCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* likesCount;



@property int32_t likesCountValue;
- (int32_t)likesCountValue;
- (void)setLikesCountValue:(int32_t)value_;

//- (BOOL)validateLikesCount:(id*)value_ error:(NSError**)error_;





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


- (NSNumber*)primitiveClipsCount;
- (void)setPrimitiveClipsCount:(NSNumber*)value;

- (int32_t)primitiveClipsCountValue;
- (void)setPrimitiveClipsCountValue:(int32_t)value_;




- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSNumber*)primitiveFollowersCount;
- (void)setPrimitiveFollowersCount:(NSNumber*)value;

- (int32_t)primitiveFollowersCountValue;
- (void)setPrimitiveFollowersCountValue:(int32_t)value_;




- (NSNumber*)primitiveLikesCount;
- (void)setPrimitiveLikesCount:(NSNumber*)value;

- (int32_t)primitiveLikesCountValue;
- (void)setPrimitiveLikesCountValue:(int32_t)value_;




- (NSString*)primitiveRemoteID;
- (void)setPrimitiveRemoteID:(NSString*)value;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;





- (NSMutableSet*)primitiveClips;
- (void)setPrimitiveClips:(NSMutableSet*)value;


@end
