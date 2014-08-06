//
//  SBAuthenticationNavigationController.m
//  Snowball
//
//  Created by James Martinez on 5/14/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAuthenticationNavigationController.h"

@interface SBAuthenticationNavigationController ()

@end

@implementation SBAuthenticationNavigationController

- (void)dismiss {
    [self switchToStoryboardWithName:@"Reels"];
}

@end
