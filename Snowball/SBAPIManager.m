//
//  SBAPIManager.m
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAPIManager.h"

static NSString * const KBBaseURL = @"http://localhost:5000/api/v1";

@implementation SBAPIManager

+ (instancetype)sharedManager {
    static SBAPIManager* sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[SBAPIManager alloc] initWithBaseURL:[NSURL URLWithString:KBBaseURL]];
    });
    return sharedManager;
}

@end
