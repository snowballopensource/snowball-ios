//
//  SBUser.m
//  Snowball
//
//  Created by James Martinez on 5/14/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAPIManager.h"
#import "SBParticipation.h"
#import "SBPushNotificationManager.h"
#import "SBReel.h"
#import "SBUser.h"

static NSString *const kSBCurrentUserRemoteID = @"SBCurrentUserRemoteID";
static NSString *const kSBCurrentUserAuthToken = @"SBCurrentUserAuthToken";

static SBUser *_currentUser = nil;

@implementation SBUser

- (NSString *)initials {
    if (self.name) {
        return [self.name initials];
    } else {
        return [self.username initials];
    }
}

#pragma mark - NSManagedObject

- (void)willSave {
    unless (self.color) [self setColor:[UIColor randomColor]];
}

#pragma mark - Current User

+ (SBUser *)currentUser {
    if (_currentUser) return _currentUser;
    SBUser *user = [SBUser MR_findFirstByAttribute:@"remoteID" withValue:[self currentUserRemoteID]];
    if ([self currentUserAuthToken] && user) {
        return user;
    } else {
        [self setCurrentUser:nil];
        return nil;
    }
}

+ (void)setCurrentUser:(SBUser *)currentUser {
    if (currentUser) {
        [[NSUserDefaults standardUserDefaults] setObject:currentUser.authToken
                                                  forKey:kSBCurrentUserAuthToken];
        [[NSUserDefaults standardUserDefaults] setObject:currentUser.remoteID
                                                  forKey:kSBCurrentUserRemoteID];
        [SBPushNotificationManager enablePushWithUserID:currentUser.remoteID];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSBCurrentUserRemoteID];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSBCurrentUserAuthToken];
        [SBPushNotificationManager disablePush];
    }

    [[NSUserDefaults standardUserDefaults] synchronize];
    _currentUser = currentUser;
    
    [[SBAPIManager sharedManager] loadAuthToken];
}

+ (NSString *)currentUserRemoteID {
    return (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:kSBCurrentUserRemoteID];
}

+ (NSString *)currentUserAuthToken {
    return (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:kSBCurrentUserAuthToken];
}

#pragma mark - Participation

- (BOOL)isParticipatingInReel:(SBReel *)reel {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ && reel == %@", self, reel];
    SBParticipation *participation = [SBParticipation MR_findFirstWithPredicate:predicate inContext:self.managedObjectContext];
    if (participation) return YES;
    return NO;
}

#pragma mark - Authentication

+ (void)facebookAuthWithAccessToken:(NSString *)accessToken
                            success:(void (^)(void))success
                            failure:(void (^)(NSError *error))failure {
    [[SBAPIManager sharedManager] POST:@"auth/facebook"
                            parameters:@{@"access_token": accessToken}
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   NSDictionary *_user = responseObject[@"user"];
                                   [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                       SBUser *user = [SBUser MR_importFromObject:_user inContext:localContext];
                                       [SBUser setCurrentUser:user];
                                   }];
                                   if (success) { success(); }
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   if (failure) { failure(error); };
                               }];
}

+ (void)signInWithEmail:(NSString *)email
               password:(NSString *)password
                success:(void (^)(void))success
                failure:(void (^)(NSError *error))failure {
    NSDictionary *parameters = @{ @"user": @{ @"email": email, @"password": password } };
    [[SBAPIManager sharedManager] POST:@"users/sign_in"
                            parameters:parameters
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   NSDictionary *_user = responseObject[@"user"];
                                   [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                       SBUser *user = [SBUser MR_importFromObject:_user inContext:localContext];
                                       [SBUser setCurrentUser:user];
                                   }];
                                   if (success) { success(); }
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   if (failure) { failure(error); };
                               }];
}

+ (void)signUpWithName:(NSString *)name
              username:(NSString *)username
                 email:(NSString *)email
              password:(NSString *)password
               success:(void (^)(void))success
               failure:(void (^)(NSError *error))failure {
    NSDictionary *parameters = @{ @"user": @{ @"name": name, @"username": username, @"email": email, @"password": password } };
    [[SBAPIManager sharedManager] POST:@"users/sign_up"
                            parameters:parameters
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   NSDictionary *_user = responseObject[@"user"];
                                   [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                       SBUser *user = [SBUser MR_importFromObject:_user inContext:localContext];
                                       [SBUser setCurrentUser:user];
                                   }];
                                   if (success) { success(); }
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   if (failure) { failure(error); };
                               }];
}

- (void)getWithSuccess:(void (^)(void))success
               failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"users/%@", self.remoteID];
    [[SBAPIManager sharedManager] GET:path
                           parameters:nil
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  NSDictionary *_user = responseObject[@"user"];
                                  [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                      [SBUser MR_importFromObject:_user inContext:localContext];
                                  }];
                                  if (success) { success(); };
                              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  if (failure) { failure(error); };
                              }];
}

#pragma mark - Finding Users

+ (void)findUsersByPhoneNumbers:(NSArray *)phoneNumbers
                           page:(NSUInteger)page
                        success:(void (^)(NSArray *users))success
                        failure:(void (^)(NSError *error))failure {
    NSMutableArray *contacts = [@[] mutableCopy];
    for (NSString *phoneNumber in phoneNumbers) {
        [contacts addObject:@{@"phone_number": phoneNumber}];
    }
    NSDictionary *parameters = @{ @"contacts": [contacts copy], @"page": @(page) };
    [[SBAPIManager sharedManager] POST:@"users/find_by_contacts"
                            parameters:parameters
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   NSArray *_users = responseObject[@"users"];
                                   __block NSArray *users;
                                   [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                       users = [SBUser MR_importFromArray:_users inContext:localContext];
                                   }];
                                   NSMutableArray *mainContextUsers = [@[] mutableCopy];
                                   for (SBUser *user in users) {
                                       [mainContextUsers addObject:[user MR_inContext:[MagicalRecordStack defaultStack].context]];
                                   }
                                   if (success) { success(mainContextUsers); }
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   if (failure) { failure(error); };
                               }];
}

#pragma mark - Following

- (void)getFollowingOnPage:(NSUInteger)page
                   success:(void (^)(BOOL canLoadMore))success
                   failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"users/%@/following", self.remoteID];
    [[SBAPIManager sharedManager] GET:path
                           parameters:@{@"page": @(page)}
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  NSArray *_users = responseObject[@"users"];
                                  [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                      [_users each:^(id object) {
                                          SBUser *user = [SBUser MR_importFromObject:object inContext:localContext];
                                          [user setFollowingValue:YES];
                                      }];
                                  }];
                                  if (success) { success([_users count]); };
                              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  if (failure) { failure(error); };
                              }];
}

- (void)followWithSuccess:(void (^)(void))success
                  failure:(void (^)(NSError *error))failure {
    [self setFollowingValue:YES];
    [self save];
    [self postFollowWithSuccess:^{
        if (success) { success(); }
    } failure:^(NSError *error) {
        if (failure) { failure(error); }
    }];
}

- (void)unfollowWithSuccess:(void (^)(void))success
                    failure:(void (^)(NSError *error))failure {
    [self setFollowingValue:NO];
    [self save];
    [self deleteFollowWithSuccess:^{
        if (success) { success(); }
    } failure:^(NSError *error) {
        if (failure) { failure(error); }
    }];
}

- (void)postFollowWithSuccess:(void (^)(void))success
                      failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"users/%@/follow", self.remoteID];
    [[SBAPIManager sharedManager] POST:path
                            parameters:nil
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   if (success) { success(); }
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                       SBUser *user = [self MR_inContext:localContext];
                                       [user setFollowingValue:NO];
                                   }];
                                   if (failure) { failure(error); };
                               }];
}

- (void)deleteFollowWithSuccess:(void (^)(void))success
                        failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"users/%@/follow", self.remoteID];
    [[SBAPIManager sharedManager] DELETE:path
                              parameters:nil
                                 success:^(NSURLSessionDataTask *task, id responseObject) {
                                     if (success) { success(); }
                                 } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                     [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                         SBUser *user = [self MR_inContext:localContext];
                                         [user setFollowingValue:YES];
                                     }];
                                     if (failure) { failure(error); };
                                 }];
}

#pragma mark - SBManagedObject

- (void)updateWithSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    NSMutableDictionary *userParameters = [@{} mutableCopy];
    if (self.name) userParameters[@"name"] = self.name;
    if (self.username) userParameters[@"username"] = self.username;
    if (self.email) userParameters[@"email"] = self.email;
    if (self.bio) userParameters[@"bio"] = self.bio;
    if (self.phoneNumber) userParameters[@"phone_number"] = self.phoneNumber;
    NSDictionary *parameters = @{ @"user": [userParameters copy] };
    NSString *path = [NSString stringWithFormat:@"users/%@", self.remoteID];
    [[SBAPIManager sharedManager] PUT:path
                           parameters:parameters
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  NSDictionary *_user = responseObject[@"user"];
                                  [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                                      [SBUser MR_importFromObject:_user inContext:localContext];
                                  }];
                                  if (success) { success(); }
                              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  if (failure) { failure(error); };
                              }];
}

@end
