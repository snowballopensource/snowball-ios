//
//  UITextField+CustomFont.m
//  Snowball
//
//  Created by James Martinez on 7/2/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "UITextField+CustomFont.h"

@implementation UITextField (CustomFont)

- (void)awakeFromNib {
    UIFont *font = [UIFont fontWithName:[UIFont snowballFontNameBook]
                                   size:self.font.pointSize];
    [self setFont:font];
}

@end
