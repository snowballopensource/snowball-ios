//
//  SBFadeOverlayView.m
//  Snowball
//
//  Created by James Martinez on 5/16/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBFadeOverlayView.h"

@interface SBFadeOverlayView ()

@end

@implementation SBFadeOverlayView

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5f]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    [gradientLayer setFrame:self.bounds];
    [gradientLayer setColors:@[
                               (id)[[[UIColor blackColor] colorWithAlphaComponent:0.5f] CGColor],
                               (id)[[UIColor blackColor] CGColor]
                               ]];
    [gradientLayer setStartPoint:CGPointMake(0.5f, 0.0f)];
    [gradientLayer setEndPoint:CGPointMake(0.5f, 1.0f)];
    [self.layer setMask:gradientLayer];
}

@end
