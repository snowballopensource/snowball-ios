//
//  SBJSONResponseSerializer.m
//  Snowball
//
//  Created by James Martinez on 5/16/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBJSONResponseSerializer.h"
#import "SBSessionManager.h"

@implementation SBJSONResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError * __autoreleasing * )error {
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        NSHTTPURLResponse *_response = (NSHTTPURLResponse *)response;
        if (_response.statusCode == 401) {
            NSLog(@"*****401*****");
            [SBSessionManager signOut];
        }
        if (*error != nil) {
            NSMutableDictionary *userInfo = [( * error).userInfo mutableCopy];
            NSDictionary *errorJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            [userInfo setValue:errorJSON[@"type"] forKey:kSnowballAPIErrorType];
            [userInfo setValue:errorJSON[@"message"] forKey:kSnowballAPIErrorMessage];
            NSError *newError = [NSError errorWithDomain:( * error).domain code:( * error).code userInfo:userInfo];
            (*error) = newError;
        }
        return (nil);
    }
    return ([super responseObjectForResponse:response data:data error:error]);
}

@end
