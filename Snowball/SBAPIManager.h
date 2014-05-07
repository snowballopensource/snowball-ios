//
//  SBAPIManager.h
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import <AFNetworking/AFHTTPSessionManager.h>

@interface SBAPIManager : AFHTTPSessionManager

+ (instancetype)sharedManager;

@end
