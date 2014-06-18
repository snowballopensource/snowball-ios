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
        parameters = @{ @"clip": @{ @"reel_attributes": @{ @"name": @"" } } };
    }
    [[SBAPIManager sharedManager] POST:path
                            parameters:parameters
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
