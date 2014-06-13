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
} SBReelRelationships;

extern const struct SBReelFetchedProperties {
} SBReelFetchedProperties;

@class SBClip;






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





@end

@interface _SBReel (CoreDataGeneratedAccessors)

- (void)addClips:(NSSet*)value_;
- (void)removeClips:(NSSet*)value_;
- (void)addClipsObject:(SBClip*)value_;
- (void)removeClipsObject:(SBClip*)value_;

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


@end
