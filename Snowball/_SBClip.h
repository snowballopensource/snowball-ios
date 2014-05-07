// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBClip.h instead.

#import <CoreData/CoreData.h>
#import "SBManagedObject.h"

extern const struct SBClipAttributes {
	__unsafe_unretained NSString *remoteID;
	__unsafe_unretained NSString *video_url;
} SBClipAttributes;

extern const struct SBClipRelationships {
} SBClipRelationships;

extern const struct SBClipFetchedProperties {
} SBClipFetchedProperties;





@interface SBClipID : NSManagedObjectID {}
@end

@interface _SBClip : SBManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SBClipID*)objectID;





@property (nonatomic, strong) NSString* remoteID;



//- (BOOL)validateRemoteID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* video_url;



//- (BOOL)validateVideo_url:(id*)value_ error:(NSError**)error_;






@end

@interface _SBClip (CoreDataGeneratedAccessors)

@end

@interface _SBClip (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveRemoteID;
- (void)setPrimitiveRemoteID:(NSString*)value;




- (NSString*)primitiveVideo_url;
- (void)setPrimitiveVideo_url:(NSString*)value;




@end
