//
//  SBSessionManager.m
//  Snowball
//
//  Created by James Martinez on 5/14/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBSessionManager.h"
#import "SBUser.h"

@implementation SBSessionManager

+ (void)setupSession {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"sessionStart"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self requestUserAuthenticationIfNecessary:NO];
}

+ (void)requestUserAuthenticationIfNecessary:(BOOL)animated {
    unless ([self validSession]) {
        if (animated) {
            [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:[self authenticationNavigationController] animated:YES completion:nil];
        }
        else {
            [[UIApplication sharedApplication].delegate.window setRootViewController:[self authenticationNavigationController]];
        }
    }
}

#pragma mark - Session Date

+ (NSDate *)sessionDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionStart"];
}

#pragma mark - Private

+ (BOOL)validSession {
    if ([SBUser currentUser]) return true;
    return false;
}

+ (UINavigationController *)authenticationNavigationController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"SBAuthenticationNavigationController"];
}

@end
