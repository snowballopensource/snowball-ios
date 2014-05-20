//
//  UINavigationBar+CustomHeight.m
//  Snowball
//
//  Created by James Martinez on 5/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "UINavigationBar+CustomHeight.h"

@implementation UINavigationBar (CustomHeight)

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.frame.size.width, 80);
}

@end
