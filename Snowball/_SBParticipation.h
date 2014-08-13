// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBParticipation.h instead.

#import <CoreData/CoreData.h>
#import "SBManagedObject.h"

extern const struct SBParticipationAttributes {
} SBParticipationAttributes;

extern const struct SBParticipationRelationships {
	__unsafe_unretained NSString *reel;
	__unsafe_unretained NSString *user;
} SBParticipationRelationships;

extern const struct SBParticipationFetchedProperties {
} SBParticipationFetchedProperties;

@class SBReel;
@class SBUser;


@interface SBParticipationID : NSManagedObjectID {}
@end

@interface _SBParticipation : SBManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SBParticipationID*)objectID;





@property (nonatomic, strong) SBReel *reel;

//- (BOOL)validateReel:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) SBUser *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;





@end

@interface _SBParticipation (CoreDataGeneratedAccessors)

@end

@interface _SBParticipation (CoreDataGeneratedPrimitiveAccessors)



- (SBReel*)primitiveReel;
- (void)setPrimitiveReel:(SBReel*)value;



- (SBUser*)primitiveUser;
- (void)setPrimitiveUser:(SBUser*)value;


@end
