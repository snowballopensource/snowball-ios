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

    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    brightness = brightness - 0.2;
    UIColor *highlightColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    [self setImageTintColor:highlightColor forState:UIControlStateHighlighted];
}

@end
