//
//  SBAnalyticsManager.m
//  Snowball
//
//  Created by James Martinez on 6/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAnalyticsManager.h"

typedef NS_ENUM(NSInteger, SBAnalyticsEvent) {
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

+ (void)sendClipCreatedEventWithReelID:(NSString *)reelID {
    NSString *source = [self clipSource];
    unless (source) source = @"";
    unless (reelID) reelID = @"";
    [self sendEvent:SBAnalyticsEventClipCreated properties:@{@"source": source,
                                                             @"reel_id": reelID}];
}

#pragma mark - Private

+ (void)sendEvent:(SBAnalyticsEvent)event properties:(NSDictionary *)properties {
    NSString *eventName = @"";
    switch (event) {
        case SBAnalyticsEventClipCreated:
            eventName = @"clip created";
            break;
        default:
            break;
    }
    NSAssert(eventName, @"SBAnalyticsEvent must be mapped to a string.");
    NSLog(@"TODO: send event: %@ %@", eventName, properties);
}

@end
