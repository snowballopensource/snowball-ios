//
//  UIButton+TintColorImage.m
//  Snowball
//
//  Created by James Martinez on 7/10/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "UIButton+TintColorImage.h"

@implementation UIButton (TintColorImage)

- (void)setImageTintColor:(UIColor *)color {
    [self setImageTintColor:color forState:UIControlStateNormal];

    const CGFloat offset = 0.2;
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    brightness = brightness - offset;
    UIColor *highlightColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    if (color == [UIColor whiteColor]) highlightColor = [UIColor colorWithWhite:1 - offset alpha:1];
    [self setImageTintColor:highlightColor forState:UIControlStateHighlighted];
}

@end
