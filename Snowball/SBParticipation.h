//
//  SBParticipation.h
//  Snowball
//
//  Created by James Martinez on 8/12/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "_SBParticipation.h"

@interface SBParticipation : _SBParticipation

+ (SBParticipation *)participationForUser:(SBUser *)user andReel:(SBReel *)reel inContext:(NSManagedObjectContext *)context;

+ (SBParticipation *)newParticipationForUser:(SBUser *)user andReel:(SBReel *)reel inContext:(NSManagedObjectContext *)context;

+ (void)createParticipationForUser:(SBUser *)user andReel:(SBReel *)reel;
+ (void)deleteParticipationForUser:(SBUser *)user andReel:(SBReel *)reel;

@end