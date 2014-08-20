//
//  SBAPIManager.m
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAPIManager.h"
#import "SBJSONResponseSerializer.h"
#import "SBUser.h"

// static NSString * const SBBaseURL = @"http://localhost:5000/api/v1";
static NSString * const SBBaseURL = @"http://snowball-production.herokuapp.com/api/v1";

@implementation SBAPIManager

+ (instancetype)sharedManager {
    static SBAPIManager* sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[SBAPIManager alloc] initWithBaseURL:[NSURL URLWithString:SBBaseURL]];
        [sharedManager setResponseSerializer:[SBJSONResponseSerializer serializer]];
        [sharedManager loadAuthToken];
    });
    return sharedManager;
}

#pragma mark - Authentication Token

- (void)loadAuthToken {
    [self.requestSerializer setAuthorizationHeaderFieldWithUsername:[SBUser currentUserAuthToken]
                                                           password:@""];
}

@end
