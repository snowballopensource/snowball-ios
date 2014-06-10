//
//  SBUserImageView.m
//  Snowball
//
//  Created by James Martinez on 6/9/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBUserImageView.h"

@implementation SBUserImageView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self.layer setCornerRadius:(self.frame.size.width/2)];
    }
    return self;
}

@end
