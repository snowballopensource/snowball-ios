//
//  SBReel.m
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAPIManager.h"
#import "SBClip.h"
#import "SBReel.h"
#import "SBSessionManager.h"
#import "SBUser.h"

@implementation SBReel

- (BOOL)hasNewClip {
    if (self.lastClipCreatedAt && self.lastWatchedClip.createdAt) {
        NSComparisonResult result = [self.lastClipCreatedAt compare:self.lastWatchedClip.createdAt];
        if (result == NSOrderedDescending) {
            return YES;
        }
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)hasPendingUpload {
    SBClip *lastClip = [self lastClip];
    if (lastClip) {
        static NSUInteger timeout = 300;
        NSUInteger timeSince = [lastClip.createdAt timeIntervalSinceNow]*-1;
        if (timeSince < timeout) {
            return (lastClip.videoURL.length < 1) ? YES : NO;
        }
    }
    return NO;
}

- (SBClip *)lastClip {
    return [SBClip MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"reel == %@", self] sortedBy:@"createdAt" ascending:NO];
}

#pragma mark - Remote

+ (void)getHomeFeedReelsOnPage:(NSUInteger)page
                       success:(void (^)(BOOL canLoadMore))success
                       failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"reels"];;
    [[SBAPIManager sharedManager] GET:path
                           parameters:@{@"page": @(page)}
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  NSArray *_reels = responseObject[@"reels"];
                                  [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                      [_reels each:^(id object) {
                                          SBReel *reel = [SBReel MR_findFirstByAttribute:@"remoteID"
                                                                               withValue:object[@"id"]
                                                                               inContext:localContext];
                                          if (reel) {
                                              [reel setParticipants:nil];
                                              [reel MR_importValuesForKeysWithObject:object];
                                          } else {
                                              [SBReel MR_importFromObject:object inContext:localContext];
                                          }
                                      }];
                                  }];
                                  if (success) { success([_reels count]); };
                              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  if (failure) { failure(error); };
                              }];
}

+ (void)getParticipantsForReel:(SBReel *)reel
                        onPage:(NSUInteger)page
                       success:(void (^)(BOOL canLoadMore))success
                       failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"reels/%@/participants", reel.remoteID];
    [[SBAPIManager sharedManager] GET:path
                           parameters:@{@"page": @(page)}
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  NSArray *_users = responseObject[@"users"];
                                  [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                      NSArray *users = [SBUser MR_importFromArray:_users inContext:localContext];
                                      SBReel *localReel = [reel MR_inContext:localContext];
                                      if (page > 1) {
                                          [localReel addParticipants:[NSSet setWithArray:users]];
                                      } else {
                                          [localReel setParticipants:[NSSet setWithArray:users]];
                                      }
                                  }];
                                  if (success) { success([_users count]); };
                              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  if (failure) { failure(error); };
                              }];
}

#pragma mark - Participants

- (void)addParticipant:(SBUser *)user
               success:(void (^)(void))success
               failure:(void (^)(NSError *error))failure {
    [user addReelsObject:self];
    [self save];
    [self postParticipant:user
                  success:^{
                      if (success) { success(); }
                  } failure:^(NSError *error) {
                      if (failure) { failure(error); }
                  }];
}

- (void)removeParticipant:(SBUser *)user
                  success:(void (^)(void))success
                  failure:(void (^)(NSError *error))failure {
    [user removeReelsObject:self];
    [self save];
    [self deleteParticipant:user
                    success:^{
                        if (success) { success(); }
                    } failure:^(NSError *error) {
                        if (failure) { failure(error); }
                    }];
}

- (void)postParticipant:(SBUser *)user
                success:(void (^)(void))success
                failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"reels/%@/participants/%@", self.remoteID, user.remoteID];
    [[SBAPIManager sharedManager] POST:path
                            parameters:nil
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   if (success) { success(); }
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                       SBUser *_user = [user MR_inContext:localContext];
                                       [_user removeReelsObject:self];
                                   }];
                                   if (failure) { failure(error); };
                               }];
}

- (void)deleteParticipant:(SBUser *)user
                  success:(void (^)(void))success
                  failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"reels/%@/participants/%@", self.remoteID, user.remoteID];
    [[SBAPIManager sharedManager] DELETE:path
                              parameters:nil
                                 success:^(NSURLSessionDataTask *task, id responseObject) {
                                     if (success) { success(); }
                                 } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                     [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                         SBUser *_user = [user MR_inContext:localContext];
                                         [_user addReelsObject:self];
                                     }];
                                     if (failure) { failure(error); };
                                 }];
}

@end
