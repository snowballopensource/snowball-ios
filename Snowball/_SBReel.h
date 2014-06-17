// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBReel.h instead.

#import <CoreData/CoreData.h>
#import "SBManagedObject.h"

extern const struct SBReelAttributes {
	__unsafe_unretained NSString *homeFeedSession;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *remoteID;
	__unsafe_unretained NSString *updatedAt;
} SBReelAttributes;

extern const struct SBReelRelationships {
	__unsafe_unretained NSString *clips;
	__unsafe_unretained NSString *participants;
	__unsafe_unretained NSString *recentParticipants;
} SBReelRelationships;

extern const struct SBReelFetchedProperties {
} SBReelFetchedProperties;

@class SBClip;
@class SBUser;
@class SBUser;






@interface SBReelID : NSManagedObjectID {}
@end

@interface _SBReel : SBManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SBReelID*)objectID;





@property (nonatomic, strong) NSDate* homeFeedSession;



//- (BOOL)validateHomeFeedSession:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* remoteID;



//- (BOOL)validateRemoteID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *clips;

- (NSMutableSet*)clipsSet;




@property (nonatomic, strong) NSSet *participants;

- (NSMutableSet*)participantsSet;




@property (nonatomic, strong) NSOrderedSet *recentParticipants;

- (NSMutableOrderedSet*)recentParticipantsSet;





@end

@interface _SBReel (CoreDataGeneratedAccessors)

- (void)addClips:(NSSet*)value_;
- (void)removeClips:(NSSet*)value_;
- (void)addClipsObject:(SBClip*)value_;
- (void)removeClipsObject:(SBClip*)value_;

- (void)addParticipants:(NSSet*)value_;
- (void)removeParticipants:(NSSet*)value_;
- (void)addParticipantsObject:(SBUser*)value_;
- (void)removeParticipantsObject:(SBUser*)value_;

- (void)addRecentParticipants:(NSOrderedSet*)value_;
- (void)removeRecentParticipants:(NSOrderedSet*)value_;
- (void)addRecentParticipantsObject:(SBUser*)value_;
- (void)removeRecentParticipantsObject:(SBUser*)value_;

@end

@interface _SBReel (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveHomeFeedSession;
- (void)setPrimitiveHomeFeedSession:(NSDate*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveRemoteID;
- (void)setPrimitiveRemoteID:(NSString*)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (NSMutableSet*)primitiveClips;
- (void)setPrimitiveClips:(NSMutableSet*)value;



- (NSMutableSet*)primitiveParticipants;
- (void)setPrimitiveParticipants:(NSMutableSet*)value;



- (NSMutableOrderedSet*)primitiveRecentParticipants;
- (void)setPrimitiveRecentParticipants:(NSMutableOrderedSet*)value;


@end
