//
//  SBUser.h
//  Snowball
//
//  Created by James Martinez on 5/14/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "_SBUser.h"

@interface SBUser : _SBUser

@property (nonatomic, strong) NSString *authToken;

+ (SBUser *)currentUser;
+ (void)removeCurrentUser;

+ (void)signInWithEmail:(NSString *)email
               password:(NSString *)password
                success:(void (^)(void))success
                failure:(void (^)(NSError *error))failure;

+ (void)signUpWithUsername:(NSString *)username
                     email:(NSString *)email
                  password:(NSString *)password
                   success:(void (^)(void))success
                   failure:(void (^)(NSError *error))failure;

- (void)getWithSuccess:(void (^)(void))success
               failure:(void (^)(NSError *error))failure;

@end
