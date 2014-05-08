//
//  SBClip.m
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAPIManager.h"
#import "SBClip.h"

@implementation SBClip

+ (void)getClipsWithSuccess:(void (^)(void))success
                    failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"clips"];;
    [[SBAPIManager sharedManager] GET:path
                           parameters:nil
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  NSArray *_clips = responseObject[@"clips"];
                                  [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                      [SBClip MR_importFromArray:_clips inContext:localContext];
                                  }];
                                  if (success) { success(); }
                              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  if (failure) { failure(error); };
                              }];
}

@end
