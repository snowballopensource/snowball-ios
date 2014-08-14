//
//  SBUserAddButton.m
//  Snowball
//
//  Created by James Martinez on 8/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBUserAddButton.h"

@implementation SBUserAddButton

- (void)setChecked:(BOOL)checked {
    if (checked) {
        [self setImage:[UIImage imageNamed:@"user-check"] forState:UIControlStateNormal];
    } else {
        [self setImage:[UIImage imageNamed:@"user-add"] forState:UIControlStateNormal];
    }
}

@end
