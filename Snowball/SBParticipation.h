//
//  SBParticipation.h
//  Snowball
//
//  Created by James Martinez on 8/12/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "_SBParticipation.h"

@interface SBParticipation : _SBParticipation

+ (SBParticipation *)createParticipationForUser:(SBUser *)user andReel:(SBReel *)reel inContext:(NSManagedObjectContext *)context;
+ (void)deleteParticipationForUser:(SBUser *)user andReel:(SBReel *)reel inContext:(NSManagedObjectContext *)context;
+ (SBParticipation *)participationForUser:(SBUser *)user andReel:(SBReel *)reel inContext:(NSManagedObjectContext *)context;
+ (SBParticipation *)createParticipationForUser:(SBUser *)user andReel:(SBReel *)reel;
+ (void)deleteParticipationForUser:(SBUser *)user andReel:(SBReel *)reel;
+ (SBParticipation *)participationForUser:(SBUser *)user andReel:(SBReel *)reel;

@end