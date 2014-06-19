//
//  SBUserTableViewCell.m
//  Snowball
//
//  Created by James Martinez on 6/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBUserTableViewCell.h"

@implementation SBUserTableViewCell

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

@end
