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
                                          [reel setParsedAt:[NSDate date]];
                                          [reel setHomeFeedSession:[SBSessionManager sessionDate]];
                                      }];
                                  }];
                                  if (success) { success([_reels count]); };
                              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  if (failure) { failure(error); };
                              }];
}

@end