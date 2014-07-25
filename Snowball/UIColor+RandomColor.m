//
//  UIColor+RandomColor.m
//  Snowball
//
//  Created by James Martinez on 7/24/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "UIColor+RandomColor.h"

@implementation UIColor (RandomColor)

+ (UIColor *)randomColor {
    CGFloat hue = (arc4random() % 256 / 256.0);  //  0.0 to 1.0
    return [UIColor colorWithHue:hue saturation:0.5 brightness:0.9 alpha:1];
}

@end
