//
//  SBClip.m
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAPIManager.h"
#import "SBClip.h"
#import "SBReel.h"
#import "SBUser.h"

@implementation SBClip

#pragma mark - MagicalRecord Import Helpers

- (BOOL)importVideoURL:(NSString *)videoURL {
    if ([videoURL length] > 0) {
        [self setVideoURL:videoURL];
    }
    return YES;
}

- (BOOL)importThumbnailURL:(NSString *)thumbnailURL {
    if ([thumbnailURL length] > 0) {
        [self setThumbnailURL:thumbnailURL];
    }
    return YES;
}

#pragma mark - Remote

+ (void)getRecentClipsForReel:(SBReel *)reel
                        since:(NSDate *)since
                      success:(void (^)(BOOL canLoadMore))success
                      failure:(void (^)(NSError *error))failure {
    NSDictionary *parameters;
    if (since) {
        parameters = @{@"since_date": @([since timeIntervalSince1970])};
    }
    NSString *path = [NSString stringWithFormat:@"reels/%@/clips", reel.remoteID];
    [[SBAPIManager sharedManager] GET:path
                           parameters:parameters
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  NSArray *_clips = responseObject[@"clips"];
                                  [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                      [SBClip MR_importFromArray:_clips inContext:localContext];
                                  }];
                                  if (success) { success([_clips count]); };
                              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  if (failure) { failure(error); };
                              }];
}

#pragma mark - SBManagedObject

- (void)createWithSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    NSString *path = @"";
    NSDictionary *parameters = nil;
    if ([self.reel.remoteID length] > 0) {
        // reel exists on server, adding to reel
        path = [NSString stringWithFormat:@"reels/%@/clips", self.reel.remoteID];
    } else {
        // reel does not exist on server, nesting it so that it is created
        path = [NSString stringWithFormat:@"clips"];
        NSMutableDictionary *reelParameters = [@{} mutableCopy];
        if (self.reel.name) {
            reelParameters[@"name"] = self.reel.name;
        } else {
            reelParameters[@"name"] = @"";
        }
        if ([self.reel.participants count] > 0) {
            NSMutableArray *participantIDs = [@[] mutableCopy];
            for (SBUser *participant in self.reel.participants) {
                [participantIDs addObject:participant.remoteID];
            }
            reelParameters[@"participant_ids"] = [participantIDs copy];;
        }
        parameters = @{ @"clip": @{ @"reel_attributes": reelParameters } };
    }
    [[SBAPIManager sharedManager] POST:path
                            parameters:parameters
             constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                 [formData appendPartWithFileData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.videoURL]]
                                             name:@"clip[video]"
                                         fileName:@"video.mp4"
                                         mimeType:@"video/mp4"];
             } success:^(NSURLSessionDataTask *task, id responseObject) {
                 [SBAnalyticsManager sendClipCreatedEventWithReelID:self.reel.remoteID];

                 NSDictionary *_clip = responseObject[@"clip"];
                 if (self.reel.remoteID == nil) {
                     // New reel just created, import reel ID to prevent duplicates showing up
                     [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                         SBReel *reel = [self.reel MR_inContext:localContext];
                         [reel setRemoteID:_clip[@"reel_id"]];
                     }];
                 }
                 [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                     SBClip *clip = [self MR_inContext:localContext];
                     [clip setRemoteID:_clip[@"id"]];
                 }];
                 [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                     SBClip *clip = [SBClip MR_importFromObject:_clip inContext:localContext];
                     [clip.reel setLastClipCreatedAt:clip.createdAt];
                 }];
                 if (success) { success(); }
             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                 static NSUInteger failureCount = 0;
                 if (failureCount < 5) {
                     [self createWithSuccess:success failure:failure];
                     failureCount++;
                 } else {
                     [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                         SBClip *clip = [self MR_inContext:localContext];
                         [clip MR_deleteEntity];
                     }];
                     [error displayInView:[UIApplication sharedApplication].delegate.window.rootViewController.view];
                     if (failure) { failure(error); };
                 }
             }];
}

@end
