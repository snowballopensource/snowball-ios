//
//  SBNavigationBar.m
//  Snowball
//
//  Created by James Martinez on 8/14/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBNavigationBar.h"

@implementation SBNavigationBar

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        //http://stackoverflow.com/a/18969325/801858
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self setShadowImage:[UIImage new]];
    }
    return self;
}

@end
