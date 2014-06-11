//
//  SBTransparentNavigationBar.m
//  Snowball
//
//  Created by James Martinez on 6/10/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBTransparentNavigationBar.h"

@implementation SBTransparentNavigationBar

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        //http://stackoverflow.com/a/18969325/801858
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self setShadowImage:[UIImage new]];
        [self setTranslucent:YES];    }
    return self;
}

@end
