//
//  UINavigationBar+CustomHeight.m
//  Snowball
//
//  Created by James Martinez on 8/14/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "UINavigationBar+CustomHeight.h"

@implementation UINavigationBar (CustomHeight)

- (CGSize)sizeThatFits:(CGSize)size {
    // Since we are hiding the status bar (20px), we add them to the height of the bar.
    return CGSizeMake(self.frame.size.width, 64);
}

@end
