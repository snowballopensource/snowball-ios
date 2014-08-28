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
    [self setupCoreData];
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

- (void)setupCoreData {
    [MagicalRecord setupAutoMigratingCoreDataStack];
    [MagicalRecord setShouldDeleteStoreOnModelMismatch:YES];
}

- (void)setupAppearance {
    // UINavigationBar
    NSDictionary *navigationBarTitleTextAttributes = @{NSFontAttributeName: [UIFont fontWithName:[UIFont snowballFontNameBook] size:20],
                                                       NSForegroundColorAttributeName: [UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:navigationBarTitleTextAttributes];
    // New status bar height: 64
    // Old status bar height: 44
    // 64-24 = 20
    // 20/2 = 10
    // yay math!
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:-10.0f forBarMetrics:UIBarMetricsDefault];
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setContentEdgeInsets:UIEdgeInsetsMake(-20.0f, 0, 0, 0)];

    // UITableViewHeaderFooterView
    [[UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setBackgroundColor:[UIColor whiteColor]];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont fontWithName:[UIFont snowballFontNameMedium] size:14.0f]];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor snowballColorBlue]];
}

@end
