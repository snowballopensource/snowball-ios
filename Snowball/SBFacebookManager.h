//
//  SBFacebookManager.h
//  Snowball
//
//  Created by James Martinez on 5/27/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBFacebookManager : NSObject

+ (void)startSession;
+ (void)signInWithSuccess:(void (^)(void))success
                  failure:(void (^)(NSError *error))failure;
+ (void)signOut;

+ (void)handleDidBecomeActive;
+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

@end
