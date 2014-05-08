//
//  SBClip.h
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "_SBClip.h"

@interface SBClip : _SBClip

+ (void)getClipsWithSuccess:(void (^)(void))success
                    failure:(void (^)(NSError *error))failure;

@end
