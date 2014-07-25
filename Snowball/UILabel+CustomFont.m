//
//  UILabel+CustomFont.m
//  Snowball
//
//  Created by James Martinez on 6/9/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "UILabel+CustomFont.h"

@implementation UILabel (CustomFont)

- (void)awakeFromNib {
    UIFont *font = [UIFont fontWithName:[UIFont snowballFontNameBook]
                                   size:self.font.pointSize];
    [self setFont:font];
}

@end
