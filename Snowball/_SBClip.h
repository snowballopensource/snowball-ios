// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBClip.h instead.

#import <CoreData/CoreData.h>
#import "SBManagedObject.h"

extern const struct SBClipAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *posterURL;
	__unsafe_unretained NSString *remoteID;
	__unsafe_unretained NSString *videoURL;
} SBClipAttributes;

extern const struct SBClipRelationships {
	__unsafe_unretained NSString *reel;
	__unsafe_unretained NSString *user;
} SBClipRelationships;

extern const struct SBClipFetchedProperties {
} SBClipFetchedProperties;

@class SBReel;
@class SBUser;






@interface SBClipID : NSManagedObjectID {}
@end

@interface _SBClip : SBManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SBClipID*)objectID;





@property (nonatomic, strong) NSNumber* createdAt;



@property int32_t createdAtValue;
- (int32_t)createdAtValue;
- (void)setCreatedAtValue:(int32_t)value_;

//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* posterURL;



//- (BOOL)validatePosterURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* remoteID;



//- (BOOL)validateRemoteID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* videoURL;



//- (BOOL)validateVideoURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) SBReel *reel;

//- (BOOL)validateReel:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) SBUser *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;





@end

@interface _SBClip (CoreDataGeneratedAccessors)

@end

@interface _SBClip (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSNumber*)value;

- (int32_t)primitiveCreatedAtValue;
- (void)setPrimitiveCreatedAtValue:(int32_t)value_;




- (NSString*)primitivePosterURL;
- (void)setPrimitivePosterURL:(NSString*)value;




- (NSString*)primitiveRemoteID;
- (void)setPrimitiveRemoteID:(NSString*)value;




- (NSString*)primitiveVideoURL;
- (void)setPrimitiveVideoURL:(NSString*)value;





- (SBReel*)primitiveReel;
- (void)setPrimitiveReel:(SBReel*)value;



- (SBUser*)primitiveUser;
- (void)setPrimitiveUser:(SBUser*)value;


@end
