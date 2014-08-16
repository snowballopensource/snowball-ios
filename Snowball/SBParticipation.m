//
//  SBParticipation.m
//  Snowball
//
//  Created by James Martinez on 8/12/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBParticipation.h"
#import "SBUser.h"
#import "SBReel.h"

@implementation SBParticipation

+ (SBParticipation *)createParticipationForUser:(SBUser *)user andReel:(SBReel *)reel inContext:(NSManagedObjectContext *)context {
    SBParticipation *participation = [self participationForUser:user andReel:reel inContext:context];
    unless (participation) {
        participation = [SBParticipation MR_createEntityInContext:context];
        [user MR_inContext:context];
        [participation setUser:[user MR_inContext:context]];
        [participation setReel:[reel MR_inContext:context]];
        [participation save];
    }
    return participation;
}

+ (SBParticipation *)createParticipationForUser:(SBUser *)user andReel:(SBReel *)reel {
    return [self createParticipationForUser:user andReel:reel inContext:[NSManagedObjectContext MR_defaultContext]];
}

+ (void)deleteParticipationForUser:(SBUser *)user andReel:(SBReel *)reel inContext:(NSManagedObjectContext *)context {
    SBParticipation *participation = [self participationForUser:user andReel:reel inContext:context];
    if (participation) {
        [participation MR_deleteEntityInContext:context];
        [participation save];
    }
}

+ (void)deleteParticipationForUser:(SBUser *)user andReel:(SBReel *)reel {
    [self deleteParticipationForUser:user andReel:reel inContext:[NSManagedObjectContext MR_defaultContext]];
}

+ (SBParticipation *)participationForUser:(SBUser *)user andReel:(SBReel *)reel inContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ && reel == %@", user, reel];
    return [SBParticipation MR_findFirstWithPredicate:predicate inContext:context];
}

+ (SBParticipation *)participationForUser:(SBUser *)user andReel:(SBReel *)reel {
    return [self participationForUser:user andReel:reel inContext:[NSManagedObjectContext MR_defaultContext]];
}

@end