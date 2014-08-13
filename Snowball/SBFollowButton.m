//
//  SBFollowButton.m
//  Snowball
//
//  Created by James Martinez on 6/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBFollowButton.h"

@implementation SBFollowButton

- (void)setFollowing:(BOOL)following {
    if (following) {
        [self setImage:[UIImage imageNamed:@"button-unfollow-normal"] forState:UIControlStateNormal];
    } else {
        [self setImage:[UIImage imageNamed:@"button-follow-normal"] forState:UIControlStateNormal];
    }
}

@end