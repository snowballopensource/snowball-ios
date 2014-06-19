//
//  UIView+ImageRepresentation.m
//  Snowball
//
//  Created by James Martinez on 6/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "UIView+ImageRepresentation.h"

@implementation UIView (ImageRepresentation)

// http://ioscodesnippet.com/2011/08/25/rendering-any-uiviews-into-uiimage-in-one-line/
- (UIImage *)imageRepresentation {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
