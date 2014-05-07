// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBClip.h instead.

#import <CoreData/CoreData.h>


extern const struct SBClipAttributes {
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *video_url;
} SBClipAttributes;

extern const struct SBClipRelationships {
} SBClipRelationships;

extern const struct SBClipFetchedProperties {
} SBClipFetchedProperties;





@interface SBClipID : NSManagedObjectID {}
@end

@interface _SBClip : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SBClipID*)objectID;





@property (nonatomic, strong) NSString* id;



//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* video_url;



//- (BOOL)validateVideo_url:(id*)value_ error:(NSError**)error_;






@end

@interface _SBClip (CoreDataGeneratedAccessors)

@end

@interface _SBClip (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;




- (NSString*)primitiveVideo_url;
- (void)setPrimitiveVideo_url:(NSString*)value;




@end
