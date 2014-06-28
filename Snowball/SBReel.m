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

- (NSArray *)recentClipPosterURLs {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reel == %@", self];
    NSFetchRequest *fetchRequest = [SBClip MR_requestAllSortedBy:@"createdAt" ascending:NO withPredicate:predicate];
    NSArray *clips = [SBClip MR_executeFetchRequest:fetchRequest];
    NSArray *lastClips;
    if ([clips count] > 5) {
        NSRange range = NSMakeRange([clips count]-5, 5);
        lastClips = [clips subarrayWithRange:range];
    } else {
        lastClips = clips;
    }
    NSMutableArray *recentClipPosterURLs = [@[] mutableCopy];
    [lastClips each:^(id object) {
        SBClip *clip = (SBClip *)object;
        if (clip.posterURL) {
            [recentClipPosterURLs addObject:clip.posterURL];
        }
    }];
    return [recentClipPosterURLs copy];
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
                                          SBReel *reel = [SBReel MR_importFromObject:object inContext:localContext];
                                          [reel setHomeFeedSession:[SBSessionManager sessionDate]];
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
