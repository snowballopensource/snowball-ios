//
//  UIButton+CustomFont.m
//  Snowball
//
//  Created by James Martinez on 6/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "UIButton+CustomFont.h"

@implementation UIButton (CustomFont)

- (void)awakeFromNib {
    UIFont *font = [UIFont fontWithName:[UIFont snowballFontNameNormal]
                                   size:self.titleLabel.font.pointSize];
    [self.titleLabel setFont:font];
}

@end