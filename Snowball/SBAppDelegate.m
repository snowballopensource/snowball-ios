//
//  SBAppDelegate.m
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAppDelegate.h"
#import "SBAnalyticsManager.h"
#import "SBPushNotificationManager.h"
#import "SBSessionManager.h"

@implementation SBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MagicalRecord setupAutoMigratingCoreDataStack];
    [SBSessionManager startSession];
    [SBPushNotificationManager setup];
    [SBAnalyticsManager start];
    [self setupAppearance];
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

#pragma mark - Private

- (void)setupAppearance {
    NSDictionary *navigationBarTitleTextAttributes = @{ NSFontAttributeName: [UIFont fontWithName:[UIFont snowballFontNameBook] size:20]};
    [[UINavigationBar appearance] setTitleTextAttributes:navigationBarTitleTextAttributes];

    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont fontWithName:[UIFont snowballFontNameBold] size:12]];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor blackColor]];

}

@end
