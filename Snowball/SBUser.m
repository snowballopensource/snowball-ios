//
//  SBUser.m
//  Snowball
//
//  Created by James Martinez on 5/14/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAPIManager.h"
#import "SBUser.h"

static NSString *const kSBCurrentUserRemoteID = @"SBCurrentUserRemoteID";
static NSString *const kSBCurrentUserAuthToken = @"SBCurrentUserAuthToken";

static SBUser *_currentUser = nil;

@implementation SBUser

@synthesize authToken;

#pragma mark - Current User

+ (SBUser *)currentUser {
    unless (_currentUser) {
        NSString *currentUserRemoteID = [[NSUserDefaults standardUserDefaults] objectForKey:kSBCurrentUserRemoteID];
        unless(currentUserRemoteID) {
            return nil;
        }
        _currentUser = [SBUser MR_findFirstByAttribute:@"remoteID" withValue:currentUserRemoteID];
        
        NSString *currentUserAuthToken = [[NSUserDefaults standardUserDefaults] objectForKey:kSBCurrentUserAuthToken];
        unless (currentUserAuthToken) {
            return nil;
        }
        [_currentUser setAuthToken:currentUserAuthToken];
    }
    return _currentUser;
}

+ (void)setCurrentUser:(SBUser *)currentUser {
    if (currentUser) {
        [[NSUserDefaults standardUserDefaults] setObject:currentUser.remoteID
                                                  forKey:kSBCurrentUserRemoteID];
        [[NSUserDefaults standardUserDefaults] setObject:currentUser.authToken
                                                  forKey:kSBCurrentUserAuthToken];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSBCurrentUserRemoteID];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSBCurrentUserAuthToken];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    _currentUser = currentUser;
    [[SBAPIManager sharedManager] loadAuthToken];
}

+ (void)removeCurrentUser {
    [self setCurrentUser:nil];
}

#pragma mark - Authentication

+ (void)signInWithEmail:(NSString *)email
               password:(NSString *)password
                success:(void (^)(void))success
                failure:(void (^)(NSError *error))failure {
    NSDictionary *parameters = @{ @"user": @{ @"email": email, @"password": password } };
    [[SBAPIManager sharedManager] POST:@"users/sign_in"
                            parameters:parameters
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   __block SBUser *user = nil;
                                   NSDictionary *_user = responseObject[@"user"];
                                   [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                       user = [SBUser MR_importFromObject:_user inContext:localContext];
                                   }];
                                   [user setAuthToken:[_user objectForKey:@"auth_token"]];
                                   [SBUser setCurrentUser:user];
                                   if (success) { success(); }
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   if (failure) { failure(error); };
                               }];
}

+ (void)signUpWithUsername:(NSString *)username
                     email:(NSString *)email
                  password:(NSString *)password
                   success:(void (^)(void))success
                   failure:(void (^)(NSError *error))failure {
    NSDictionary *parameters = @{ @"user": @{ @"username": username, @"email": email, @"password": password } };
    [[SBAPIManager sharedManager] POST:@"users/sign_up"
                            parameters:parameters
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   __block SBUser *user = nil;
                                   NSDictionary *_user = responseObject[@"user"];
                                   [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                       user = [SBUser MR_importFromObject:_user inContext:localContext];
                                   }];
                                   [user setAuthToken:[_user objectForKey:@"auth_token"]];
                                   [SBUser setCurrentUser:user];
                                   if (success) { success(); }
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   if (failure) { failure(error); };
                               }];
}

#pragma mark - SBManagedObject

- (void)updateWithSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure {
//    NSMutableDictionary *userParameters = [NSMutableDictionary new];
//    userParameters[@"name"] = self.name;
//    userParameters[@"username"] = self.username;
//    userParameters[@"email"] = self.email;
//    NSDictionary *parameters = @{ @"user": [userParameters copy] };
//    NSString *path = [NSString stringWithFormat:@"users/%@", [GLUser currentUser].remoteID];
//    [[GLAPIManager sharedManager] PUT:path
//                           parameters:parameters
//                              success:^(NSURLSessionDataTask *task, id responseObject) {
//                                  NSDictionary *_user = responseObject[@"user"];
//                                  [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
//                                      GLUser *user = [self MR_inContext:localContext];
//                                      [user MR_importValuesForKeysWithObject:_user];
//                                  }];
//                                  if (success) { success(); }
//                              } failure:^(NSURLSessionDataTask *task, NSError *error) {
//                                  if (failure) { failure(error); };
//                              }];
}

@end
