//
//  SBUser.h
//  Snowball
//
//  Created by James Martinez on 5/14/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "_SBUser.h"

@class SBReel;

@interface SBUser : _SBUser

@property (nonatomic, strong) NSString *authToken;

+ (SBUser *)currentUser;
+ (void)removeCurrentUser;

- (BOOL)isParticipatingInReel:(SBReel *)reel;

+ (void)facebookAuthWithAccessToken:(NSString *)accessToken
                            success:(void (^)(void))success
                            failure:(void (^)(NSError *error))failure;

+ (void)signInWithEmail:(NSString *)email
               password:(NSString *)password
                success:(void (^)(void))success
                failure:(void (^)(NSError *error))failure;

+ (void)signUpWithName:(NSString *)name
              username:(NSString *)username
                 email:(NSString *)email
              password:(NSString *)password
               success:(void (^)(void))success
               failure:(void (^)(NSError *error))failure;

- (void)getWithSuccess:(void (^)(void))success
               failure:(void (^)(NSError *error))failure;

+ (void)findUsersByPhoneNumbers:(NSArray *)phoneNumbers
                           page:(NSUInteger)page
                        success:(void (^)(NSArray *users))success
                        failure:(void (^)(NSError *error))failure;

- (void)getFollowingOnPage:(NSUInteger)page
                   success:(void (^)(BOOL canLoadMore))success
                   failure:(void (^)(NSError *error))failure;

- (void)followWithSuccess:(void (^)(void))success
                  failure:(void (^)(NSError *error))failure;

- (void)unfollowWithSuccess:(void (^)(void))success
                    failure:(void (^)(NSError *error))failure;

@end
