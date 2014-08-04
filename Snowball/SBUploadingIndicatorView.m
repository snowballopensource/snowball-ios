//
//  SBUploadingIndicatorView.m
//  Snowball
//
//  Created by James Martinez on 7/30/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBUploadingIndicatorView.h"

@interface SBUploadingIndicatorView ()

@property (nonatomic, strong) UIImageView *uploadingImageView;

@property (nonatomic) BOOL animating;

@end

@implementation SBUploadingIndicatorView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"icon-airplane"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [self setUploadingImageView:imageView];
        [self addSubview:self.uploadingImageView];
    }
    return self;
}

- (void)beginAnimating {
    unless (self.animating) {
        CGFloat leftOriginX = self.uploadingImageView.frame.size.width * -1;
        CGFloat rightOriginX = self.frame.size.width + self.uploadingImageView.frame.size.width;
        CGFloat centerY = (self.bounds.size.height / 2) - (self.uploadingImageView.frame.size.height / 2);

        [self.uploadingImageView setFrame:CGRectMake(leftOriginX, centerY, self.uploadingImageView.frame.size.width, self.uploadingImageView.frame.size.height)];

        [UIView animateWithDuration:1.5
                              delay:0
                            options:UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [UIView setAnimationRepeatCount:INFINITY];
                             [self.uploadingImageView setFrame:CGRectMake(rightOriginX, centerY, self.uploadingImageView.frame.size.width, self.uploadingImageView.frame.size.height)];
                         }
                         completion:^(BOOL finished) {
                             [self setAnimating:NO];
                         }];
    }
}

- (void)endAnimating {
    [self.layer removeAllAnimations];
    [self.uploadingImageView.layer removeAllAnimations];
    [self setAnimating:NO];
}

@end
