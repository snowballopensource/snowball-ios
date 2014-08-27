// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBClip.h instead.

#import <CoreData/CoreData.h>
#import "SBManagedObject.h"

extern const struct SBClipAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *remoteID;
	__unsafe_unretained NSString *thumbnailURL;
	__unsafe_unretained NSString *videoURL;
} SBClipAttributes;

extern const struct SBClipRelationships {
	__unsafe_unretained NSString *lastForReel;
	__unsafe_unretained NSString *lastWatchedForReel;
	__unsafe_unretained NSString *reel;
	__unsafe_unretained NSString *user;
} SBClipRelationships;

extern const struct SBClipFetchedProperties {
} SBClipFetchedProperties;

@class SBReel;
@class SBReel;
@class SBReel;
@class SBUser;






@interface SBClipID : NSManagedObjectID {}
@end

@interface _SBClip : SBManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SBClipID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* remoteID;



//- (BOOL)validateRemoteID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbnailURL;



//- (BOOL)validateThumbnailURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* videoURL;



//- (BOOL)validateVideoURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) SBReel *lastForReel;

//- (BOOL)validateLastForReel:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) SBReel *lastWatchedForReel;

//- (BOOL)validateLastWatchedForReel:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) SBReel *reel;

//- (BOOL)validateReel:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) SBUser *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;





@end

@interface _SBClip (CoreDataGeneratedAccessors)

@end

@interface _SBClip (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveRemoteID;
- (void)setPrimitiveRemoteID:(NSString*)value;




- (NSString*)primitiveThumbnailURL;
- (void)setPrimitiveThumbnailURL:(NSString*)value;




- (NSString*)primitiveVideoURL;
- (void)setPrimitiveVideoURL:(NSString*)value;





- (SBReel*)primitiveLastForReel;
- (void)setPrimitiveLastForReel:(SBReel*)value;



- (SBReel*)primitiveLastWatchedForReel;
- (void)setPrimitiveLastWatchedForReel:(SBReel*)value;



- (SBReel*)primitiveReel;
- (void)setPrimitiveReel:(SBReel*)value;



- (SBUser*)primitiveUser;
- (void)setPrimitiveUser:(SBUser*)value;


@end
