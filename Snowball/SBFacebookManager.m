//
//  SBFacebookManager.m
//  Snowball
//
//  Created by James Martinez on 5/27/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBFacebookManager.h"
#import "SBSessionManager.h"
#import "SBUser.h"

@interface SBFacebookManager ()

@property (nonatomic, copy) void(^authenticationSuccessBlock)(void);
@property (nonatomic, copy) void(^authenticationFailureBlock)(NSError *error);

@end

@implementation SBFacebookManager

+ (instancetype)sharedManager {
    static SBFacebookManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [SBFacebookManager new];
    });
    return sharedManager;
}

#pragma mark - Session

+ (void)startSession {
    [[self sharedManager] createSessionAllowingSignInUI:NO success:nil failure:nil];
}

+ (void)signInWithSuccess:(void (^)(void))success
                  failure:(void (^)(NSError *error))failure {
    [[self sharedManager] createSessionAllowingSignInUI:YES success:success failure:failure];
}

+ (void)signOut {
    [FBSession.activeSession closeAndClearTokenInformation];
}

#pragma mark - Private

- (void)createSessionAllowingSignInUI:(BOOL)allowSignInUI
                              success:(void (^)(void))success
                              failure:(void (^)(NSError *error))failure {
    if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        [FBSession.activeSession closeAndClearTokenInformation];
    } else {
        [self setAuthenticationSuccessBlock:success];
        [self setAuthenticationFailureBlock:failure];

        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email"]
                                           allowLoginUI:allowSignInUI
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             [self sessionStateChanged:session state:state error:error];
         }];
    }
}

#pragma mark - Handlers

+ (void)handleDidBecomeActive {
    [FBAppCall handleDidBecomeActive];
}

+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    [FBSession.activeSession setStateChangeHandler:^(FBSession *session, FBSessionState state, NSError *error) {
        [[self sharedManager] sessionStateChanged:session state:state error:error];
    }];
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error {
    if (!error && state == FBSessionStateOpen){
        if (![SBSessionManager validSession]) {
            [SBUser facebookAuthWithAccessToken:session.accessTokenData.accessToken
                                        success:^{
                                            if (self.authenticationSuccessBlock) {
                                                self.authenticationSuccessBlock();
                                            }
                                        } failure:^(NSError *error) {
                                            if (self.authenticationFailureBlock) {
                                                self.authenticationFailureBlock(error);
                                            }
                                        }];
        }
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        [SBFacebookManager signOut];
    }
    // Handle errors
    if (error){
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [[[UIAlertView alloc] initWithTitle:alertTitle message:alertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [[[UIAlertView alloc] initWithTitle:alertTitle message:alertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else {
                NSDictionary *errorInformation = (error.userInfo)[@"com.facebook.sdk:ParsedJSONResponseKey"][@"body"][@"error"];
                
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", errorInformation[@"message"]];
                [[[UIAlertView alloc] initWithTitle:alertTitle message:alertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
        [SBFacebookManager signOut];
    }
}

@end
