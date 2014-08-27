//
//  SBReel.h
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "_SBReel.h"

@class SBClip;
@class SBUser;

@interface SBReel : _SBReel

- (BOOL)hasNewClip;
- (NSArray *)playerClips;
- (BOOL)hasPendingUpload;

- (void)setParticipants:(NSArray *)users;
- (void)addParticipants:(NSArray *)users;

+ (void)getHomeFeedReelsOnPage:(NSUInteger)page
                       success:(void (^)(BOOL canLoadMore))success
                       failure:(void (^)(NSError *error))failure;

- (void)getParticipantsOnPage:(NSUInteger)page
                       success:(void (^)(BOOL canLoadMore))success
                       failure:(void (^)(NSError *error))failure;

- (void)addParticipant:(SBUser *)user
               success:(void (^)(void))success
               failure:(void (^)(NSError *error))failure;

- (void)removeParticipant:(SBUser *)user
                  success:(void (^)(void))success
                  failure:(void (^)(NSError *error))failure;

@end
