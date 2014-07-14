//
//  SBAnalyticsManager.m
//  Snowball
//
//  Created by James Martinez on 6/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAnalyticsManager.h"

@implementation SBAnalyticsManager

+ (void)start {
#ifndef DEBUG
    [Crittercism enableWithAppID:@"53a389b5d478bc6de400000a"];
#endif
}

@end
