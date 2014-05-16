//
//  SBReel.h
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "_SBReel.h"

@interface SBReel : _SBReel

- (NSArray *)recentClipPosterURLs;

+ (void)getRecentReelsOnPage:(NSUInteger)page
                     success:(void (^)(BOOL canLoadMore))success
                     failure:(void (^)(NSError *error))failure;

@end
