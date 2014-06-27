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

#pragma mark - Actions

- (IBAction)followUserButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(followUserButtonPressedInCell:)]) {
        [self.delegate followUserButtonPressedInCell:self];
    }
}

- (IBAction)checkUserButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(checkUserButtonPressedInCell:)]) {
        [self.delegate checkUserButtonPressedInCell:self];
    }
}

#pragma mark - Setters / Getters

- (void)setStyle:(SBUserTableViewCellStyle)style {
    switch (style) {
        case SBUserTableViewCellStyleSelectable:
            [self.followButton setHidden:YES];
            [self.checkButton setHidden:NO];
            break;
        case SBUserTableViewCellStyleFollowable:
            [self.followButton setHidden:NO];
            [self.checkButton setHidden:YES];
            break;
        default:
            [self.followButton setHidden:YES];
            [self.checkButton setHidden:YES];
            break;
    }
    _style = style;
}

@end
