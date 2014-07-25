//
//  UIImageView+TintColor.m
//  Snowball
//
//  Created by James Martinez on 7/24/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "UIImageView+TintColor.h"

@implementation UIImageView (TintColor)

- (void)setImageTintColor:(UIColor *)color {
    [self setImage:[self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self setTintColor:color];
}

@end
