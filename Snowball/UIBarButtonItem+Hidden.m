//
//  UIBarButtonItem+Hidden.m
//  Snowball
//
//  Created by James Martinez on 6/10/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "UIBarButtonItem+Hidden.h"

@implementation UIBarButtonItem (Hidden)

- (void)setHidden:(BOOL)hidden {
    // My spin on
    // http://stackoverflow.com/a/16364449/801858
    if (hidden) {
        [self setTitle:@" "];
    } else {
        [self setTitle:nil];
    }
    [self setEnabled:!hidden];
}

@end
