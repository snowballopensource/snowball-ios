//
//  SBDeepLinkManager.m
//  Snowball
//
//  Created by James Martinez on 7/25/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBDeepLinkManager.h"

#import "SBReelClipsViewController.h"

@implementation SBDeepLinkManager

+ (BOOL)handleDeepLinkURL:(NSURL *)url {
    // Extract remote ID and remove "/" in path (e.g. "/12345" to "12345")
    NSString *remoteID = @"";
    if ([[url path] length] > 1) {
        remoteID = [[url path] substringFromIndex:1];
    }

    if ([[url host] isEqualToString:@"reel"] && [remoteID length] > 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        // ECSlidingViewController *slidingVC = [storyboard instantiateInitialViewController];
        // UINavigationController *nc = (UINavigationController *)slidingVC.topViewController;
        SBReelClipsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:[SBReelClipsViewController identifier]];
        [vc setReelID:remoteID];
        [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:vc animated:YES completion:nil];
        // [nc pushViewController:vc animated:YES];

        return YES;
    }
    return NO;
}

@end
