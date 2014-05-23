//
//  SBPushNotificationManager.h
//  Snowball
//
//  Created by James Martinez on 5/23/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBPushNotificationManager : NSObject

+ (void)setup;
+ (void)enablePushWithUserID:(NSString *)userID;
+ (void)disablePush;

@end
