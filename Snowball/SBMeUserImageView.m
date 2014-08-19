//
//  SBMeUserImageView.m
//  Snowball
//
//  Created by James Martinez on 6/18/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBMeUserImageView.h"
#import "SBUser.h"

@implementation SBMeUserImageView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setImageWithUser:[SBUser currentUser]];
    }
    return self;
}

@end
