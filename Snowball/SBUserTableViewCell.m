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

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    
    [self.nameLabel setTextColor:tintColor];
    [self.addButton setImageTintColor:tintColor];
}

#pragma mark - Actions

- (IBAction)cellSelected:(id)sender {
    if ([self.delegate respondsToSelector:@selector(userCellSelected:)]) {
        [self.delegate userCellSelected:self];
    }
}

#pragma mark - Setters / Getters

- (void)setStyle:(SBUserTableViewCellStyle)style {
    switch (style) {
        case SBUserTableViewCellStyleSelectable:
            [self.addButton setHidden:NO];
            break;
        default:
            [self.addButton setHidden:YES];
            break;
    }
}

@end
