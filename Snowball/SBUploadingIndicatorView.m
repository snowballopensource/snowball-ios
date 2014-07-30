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

@end

@implementation SBUploadingIndicatorView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        UIImageView *uploadingIndicator = [[UIImageView alloc] initWithFrame:self.bounds];
        [uploadingIndicator setImage:[UIImage imageNamed:@"icon-airplane"]];
        [uploadingIndicator setContentMode:UIViewContentModeCenter];
        [self addSubview:uploadingIndicator];
        [self setUploadingIndicator:uploadingIndicator];
        [self animate:YES];
    }
    return self;
}

- (void)animate:(BOOL)animate {
    static CGFloat defaultUploadingIndicatorCenterX = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultUploadingIndicatorCenterX = self.uploadingIndicator.center.x;
    });
    CGFloat leftCenterX = defaultUploadingIndicatorCenterX * -1;
    CGFloat rightCenterX = self.frame.size.width + defaultUploadingIndicatorCenterX;
    [self.uploadingIndicator setCenter:CGPointMake(leftCenterX, self.uploadingIndicator.center.y)];
    [UIView animateWithDuration:4
                          delay:0
                        options:UIViewAnimationOptionRepeat
                     animations:^{
                         [self.uploadingIndicator setCenter:CGPointMake(rightCenterX, self.uploadingIndicator.center.y)];
                     }
                     completion:nil];
}

@end
