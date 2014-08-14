// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBReel.h instead.

#import <CoreData/CoreData.h>
#import "SBManagedObject.h"

extern const struct SBReelAttributes {
	__unsafe_unretained NSString *color;
	__unsafe_unretained NSString *lastClipCreatedAt;
	__unsafe_unretained NSString *lastClipThumbnailURL;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *recentParticipantsNames;
	__unsafe_unretained NSString *remoteID;
} SBReelAttributes;

extern const struct SBReelRelationships {
	__unsafe_unretained NSString *clips;
	__unsafe_unretained NSString *lastWatchedClip;
	__unsafe_unretained NSString *participations;
} SBReelRelationships;

extern const struct SBReelFetchedProperties {
} SBReelFetchedProperties;

@class SBClip;
@class SBClip;
@class SBParticipation;

@class NSObject;






@interface SBReelID : NSManagedObjectID {}
@end

@interface _SBReel : SBManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SBReelID*)objectID;





@property (nonatomic, strong) id color;



//- (BOOL)validateColor:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastClipCreatedAt;



//- (BOOL)validateLastClipCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* lastClipThumbnailURL;



//- (BOOL)validateLastClipThumbnailURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* recentParticipantsNames;



//- (BOOL)validateRecentParticipantsNames:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* remoteID;



//- (BOOL)validateRemoteID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *clips;

- (NSMutableSet*)clipsSet;




@property (nonatomic, strong) SBClip *lastWatchedClip;

//- (BOOL)validateLastWatchedClip:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *participations;

- (NSMutableSet*)participationsSet;





@end

@interface _SBReel (CoreDataGeneratedAccessors)

- (void)addClips:(NSSet*)value_;
- (void)removeClips:(NSSet*)value_;
- (void)addClipsObject:(SBClip*)value_;
- (void)removeClipsObject:(SBClip*)value_;

- (void)addParticipations:(NSSet*)value_;
- (void)removeParticipations:(NSSet*)value_;
- (void)addParticipationsObject:(SBParticipation*)value_;
- (void)removeParticipationsObject:(SBParticipation*)value_;

@end

@interface _SBReel (CoreDataGeneratedPrimitiveAccessors)


- (id)primitiveColor;
- (void)setPrimitiveColor:(id)value;




- (NSDate*)primitiveLastClipCreatedAt;
- (void)setPrimitiveLastClipCreatedAt:(NSDate*)value;




- (NSString*)primitiveLastClipThumbnailURL;
- (void)setPrimitiveLastClipThumbnailURL:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveRecentParticipantsNames;
- (void)setPrimitiveRecentParticipantsNames:(NSString*)value;




- (NSString*)primitiveRemoteID;
- (void)setPrimitiveRemoteID:(NSString*)value;





- (NSMutableSet*)primitiveClips;
- (void)setPrimitiveClips:(NSMutableSet*)value;



- (SBClip*)primitiveLastWatchedClip;
- (void)setPrimitiveLastWatchedClip:(SBClip*)value;



- (NSMutableSet*)primitiveParticipations;
- (void)setPrimitiveParticipations:(NSMutableSet*)value;


@end
