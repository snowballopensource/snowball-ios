//
//  SBTransparentNavigationBar.m
//  Snowball
//
//  Created by James Martinez on 6/10/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBTransparentNavigationBar.h"

@implementation SBTransparentNavigationBar

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        //http://stackoverflow.com/a/18969325/801858
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self setShadowImage:[UIImage new]];
        [self setTranslucent:YES];
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // This is an ugly little hack to allow touches to pass through the nav bar
    // if tapped on the right side of the screen. This allows for the flip camera
    // button to be located underneath the navbar.
    BOOL pointInside = NO;
    for (UIView *view in self.subviews) {
        if (CGRectContainsPoint(view.frame, point)) {
            pointInside = YES;
            if ([[NSString stringWithFormat:@"%@", view.class] isEqualToString:@"_UINavigationBarBackground"]) {
                CGFloat oneThird = self.frame.size.width / 3;
                CGRect rightThird = CGRectMake(self.frame.origin.x + oneThird * 2,
                                               self.frame.origin.y,
                                               oneThird,
                                               self.frame.size.height);
                if (CGRectContainsPoint(rightThird, point)) {
                    pointInside = NO;
                }
            }
        }
    }
    return pointInside;
}

@end
