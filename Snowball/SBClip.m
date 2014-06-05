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

@implementation SBClip

@synthesize videoToSubmit;

#pragma mark - Like

- (void)likeWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    [self setLikedValue:YES];
    [self setLikesCountValue:self.likesCountValue+1];
    [self save];
    [self postLikeWithSuccess:^{
        if (success) { success(); };
    } failure:^(NSError *error) {
        if (failure) { failure(error); };
    }];
}

- (void)unlikeWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    [self setLikedValue:NO];
    [self setLikesCountValue:self.likesCountValue-1];
    [self save];
    [self deleteLikeWithSuccess:^{
        if (success) { success(); };
    } failure:^(NSError *error) {
        if (failure) { failure(error); };
    }];
}

#pragma mark - Remote

+ (void)getRecentClipsForReel:(SBReel *)reel
                         page:(NSUInteger)page
                      success:(void (^)(BOOL canLoadMore))success
                      failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"reels/%@/clips", reel.remoteID];;
    [[SBAPIManager sharedManager] GET:path
                           parameters:@{@"page": @(page)}
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

- (void)postLikeWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"clips/%@/likes", self.remoteID];
    [[SBAPIManager sharedManager] POST:path
                            parameters:nil
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                       SBClip *clip = [self MR_inContext:localContext];
                                       NSInteger statusCode = [(NSHTTPURLResponse *)task.response statusCode];
                                       BOOL liked = (statusCode == 201) ? YES : NO;
                                       [clip setLikedValue:liked];
                                   }];
                                   if (success) { success(); };
                               }
                               failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                       SBClip *clip = [self MR_inContext:localContext];
                                       [clip setLikedValue:NO];
                                   }];
                                   if (failure) { failure(error); };
                               }];
}

- (void)deleteLikeWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"clips/%@/likes", self.remoteID];
    [[SBAPIManager sharedManager] DELETE:path
                              parameters:nil
                                 success:^(NSURLSessionDataTask *task, id responseObject) {
                                     [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                         SBClip *clip = [self MR_inContext:localContext];
                                         NSInteger statusCode = [(NSHTTPURLResponse *)task.response statusCode];
                                         BOOL liked = (statusCode == 204) ? NO : YES;
                                         [clip setLikedValue:liked];
                                     }];
                                     if (success) { success(); };
                                 }
                                 failure:^(NSURLSessionDataTask *task, NSError *error) {
                                     [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                         SBClip *clip = [self MR_inContext:localContext];
                                         [clip setLikedValue:YES];
                                     }];
                                     if (failure) { failure(error); };
                                 }];
}

#pragma mark - SBManagedObject

- (void)createWithSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"reels/%@/clips", self.reel.remoteID];
    [[SBAPIManager sharedManager] POST:path
                            parameters:nil
             constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                 [formData appendPartWithFileData:self.videoToSubmit
                                             name:@"clip[video]"
                                         fileName:@"video.mp4"
                                         mimeType:@"video/mp4"];
             } success:^(NSURLSessionDataTask *task, id responseObject) {
                 NSDictionary *_clip = responseObject[@"clip"];
                 [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                     SBClip *clip = [self MR_inContext:localContext];
                     [clip MR_importValuesForKeysWithObject:_clip];
                 }];
                 if (success) { success(); }
             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                 [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                     SBClip *clip = [self MR_inContext:localContext];
                     [clip MR_deleteEntity];
                 }];
                 if (failure) { failure(error); };
             }];
}

@end
