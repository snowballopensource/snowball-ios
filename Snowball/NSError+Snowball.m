//
//  NSError+Snowball.m
//  Snowball
//
//  Created by James Martinez on 5/16/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "NSError+Snowball.h"

@implementation NSError (Snowball)

- (NSString *)userAppropriateErrorMessage {
    if ([self.userInfo[kSnowballAPIErrorMessage] length] > 0) {
        return self.userInfo[kSnowballAPIErrorMessage];
    }
    else {
        return @"Sorry, we couldn't complete your request. Please try again in a moment.";
    }
}

- (void)displayInView:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    [hud setMode:MBProgressHUDModeText];
    [hud setDetailsLabelText:[self userAppropriateErrorMessage]];
    [hud setDetailsLabelFont:[UIFont boldSystemFontOfSize:15]];
    [hud hide:YES afterDelay:2];
}

@end
