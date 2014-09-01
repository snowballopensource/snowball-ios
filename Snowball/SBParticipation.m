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

+ (SBParticipation *)participationForUser:(SBUser *)user andReel:(SBReel *)reel inContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ && reel == %@", user, reel];
    return [SBParticipation MR_findFirstWithPredicate:predicate inContext:context];
}

+ (SBParticipation *)newParticipationForUser:(SBUser *)user andReel:(SBReel *)reel inContext:(NSManagedObjectContext *)context {
    SBParticipation *participation = [self participationForUser:user andReel:reel inContext:context];
    unless (participation) {
        participation = [SBParticipation MR_createEntityInContext:context];
        [user MR_inContext:context];
        [participation setUser:[user MR_inContext:context]];
        [participation setReel:[reel MR_inContext:context]];
    }
    return participation;
}

+ (void)createParticipationForUser:(SBUser *)user andReel:(SBReel *)reel {
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        [SBParticipation newParticipationForUser:user andReel:reel inContext:localContext];
    }];
}

+ (void)deleteParticipationForUser:(SBUser *)user andReel:(SBReel *)reel {
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        SBParticipation *participation = [self participationForUser:user andReel:reel inContext:localContext];
        [participation MR_deleteEntityInContext:localContext];
    }];
}

@end