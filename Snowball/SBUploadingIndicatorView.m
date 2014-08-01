//
//  SBUploadingIndicatorView.m
//  Snowball
//
//  Created by James Martinez on 7/30/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBUploadingIndicatorView.h"

@interface SBUploadingIndicatorView ()

@property (nonatomic, strong) UIImageView *uploadingIndicator;

@property (nonatomic) BOOL animating;

@end

@implementation SBUploadingIndicatorView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"icon-airplane"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [self setUploadingIndicator:imageView];
        [self addSubview:self.uploadingIndicator];
    }
    return self;
}

- (void)beginAnimating {
    unless (self.animating) {
        CGFloat leftOriginX = self.uploadingIndicator.frame.size.width * -1;
        CGFloat rightOriginX = self.frame.size.width + self.uploadingIndicator.frame.size.width;
        [self.uploadingIndicator setFrame:CGRectMake(leftOriginX, self.uploadingIndicator.frame.origin.y, self.uploadingIndicator.frame.size.width, self.uploadingIndicator.frame.size.height)];
        [UIView animateWithDuration:1.5
                              delay:0
                            options:UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [UIView setAnimationRepeatCount:INFINITY];
                             [self.uploadingIndicator setFrame:CGRectMake(rightOriginX, self.uploadingIndicator.frame.origin.y, self.uploadingIndicator.frame.size.width, self.uploadingIndicator.frame.size.height)];
                         }
                         completion:^(BOOL finished) {
                             [self setAnimating:NO];
                         }];
    }
}

- (void)endAnimating {
    [self.layer removeAllAnimations];
    [self.uploadingIndicator.layer removeAllAnimations];
    [self setAnimating:NO];
}

@end
