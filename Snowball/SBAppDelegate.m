//
//  SBAppDelegate.m
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAppDelegate.h"
#import "SBPushNotificationManager.h"
#import "SBSessionManager.h"

@implementation SBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MagicalRecord setupCoreDataStack];
    [SBSessionManager startSession];
    [SBPushNotificationManager setup];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [SBSessionManager handleDidBecomeActive];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [SBSessionManager handleOpenURL:url sourceApplication:sourceApplication];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [MagicalRecord cleanUp];
}

@end
