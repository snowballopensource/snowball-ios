//
//  SBClip.h
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "_SBClip.h"

@interface SBClip : _SBClip

+ (void)getRecentClipsForReel:(SBReel *)reel
                        since:(NSDate *)since
                      success:(void (^)(BOOL canLoadMore))success
                      failure:(void (^)(NSError *error))failure;

@end
