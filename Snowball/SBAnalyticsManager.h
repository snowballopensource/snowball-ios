//
//  SBAnalyticsManager.h
//  Snowball
//
//  Created by James Martinez on 6/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVCaptureDevice.h>

@interface SBAnalyticsManager : NSObject

+ (void)start;

+ (void)sendAppLaunchedEventWithLaunchOptions:(NSDictionary *)launchOptions;
+ (void)setClipSourceFromCameraPosition:(AVCaptureDevicePosition)position;

+ (void)sendClipCreatedEventWithReelID:(NSString *)reelID;

@end
