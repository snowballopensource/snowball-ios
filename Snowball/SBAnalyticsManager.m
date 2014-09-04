//
//  SBAnalyticsManager.m
//  Snowball
//
//  Created by James Martinez on 6/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAnalyticsManager.h"

typedef NS_ENUM(NSInteger, SBAnalyticsEvent) {
    SBAnalyticsEventAppLaunched,
    SBAnalyticsEventClipCreated
};

@implementation SBAnalyticsManager

+ (void)start {
#ifndef DEBUG
    [Crittercism enableWithAppID:@"53a389b5d478bc6de400000a"];
#endif
}

#pragma mark - Analytics Specific Properties Setters / Getters

+ (void)setClipSourceFromCameraPosition:(AVCaptureDevicePosition)position {
    switch (position) {
        case AVCaptureDevicePositionFront:
            [self setClipSource:@"front camera"];
            break;
        case AVCaptureDevicePositionBack:
            [self setClipSource:@"back camera"];
        default:
            break;
    }
}

+ (void)setClipSource:(NSString *)clipSource {
    [[NSUserDefaults standardUserDefaults] setObject:clipSource forKey:@"analytics.clip_source"];
}

+ (NSString *)clipSource {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"analytics.clip_source"];
}

#pragma mark - Events

+ (void)sendAppLaunchedEventWithLaunchOptions:(NSDictionary *)launchOptions {
    NSDictionary *properties = nil;
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        properties = @{@"Source": @"Push Notification"};
    }
    [self sendEvent:SBAnalyticsEventAppLaunched properties:properties];
}

+ (void)sendClipCreatedEventWithReelID:(NSString *)reelID {
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    NSString *source = [self clipSource];
    if (source) properties[@"Source"] = source;
    if (reelID) properties[@"Reel ID"] = reelID;
    [self sendEvent:SBAnalyticsEventClipCreated properties:[properties copy]];
}

#pragma mark - Private

+ (void)sendEvent:(SBAnalyticsEvent)event properties:(NSDictionary *)properties {
    NSString *eventName = @"";
    switch (event) {
        case SBAnalyticsEventAppLaunched:
            eventName = @"App Launched";
            break;
        case SBAnalyticsEventClipCreated:
            eventName = @"Clip Created";
            break;
        default:
            break;
    }
    NSAssert(eventName, @"SBAnalyticsEvent must be mapped to a string.");
    NSLog(@"EVENT: %@, %@", eventName, properties);
#ifndef DEBUG
    // TODO: send event
#endif
}

@end
