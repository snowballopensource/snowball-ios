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
    UIImage *image = nil;
    if (checked) {
        image = [UIImage imageNamed:@"user-check"];
    } else {
        image = [UIImage imageNamed:@"user-add"];
    }
    [self setImage:image forState:UIControlStateNormal];
}

@end
