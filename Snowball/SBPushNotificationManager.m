//
//  SBPushNotificationManager.m
//  Snowball
//
//  Created by James Martinez on 5/23/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBPushNotificationManager.h"

@implementation SBPushNotificationManager

+ (void)setup {
    // Build settings are in AirshipConfig.plist
    [UAirship takeOff];
    [UAPush setDefaultPushEnabledValue:NO];
}

+ (void)enablePushWithUserID:(NSString *)userID {
    [[UAPush shared] setAlias:userID];
    [[UAPush shared] setPushEnabled:YES];
}

+ (void)disablePush {
    [[UAPush shared] setAlias:nil];
    [[UAPush shared] setPushEnabled:NO];
}

@end
