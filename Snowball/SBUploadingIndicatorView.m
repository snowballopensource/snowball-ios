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
        UIImage *uploadingIcon = [UIImage imageNamed:@"icon-airplane"];
        UIImageView *uploadingIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, uploadingIcon.size.width, uploadingIcon.size.height)];
        [uploadingIndicator setImage:uploadingIcon];
        [uploadingIndicator setCenter:self.center];
        [self addSubview:uploadingIndicator];
        [self setUploadingIndicator:uploadingIndicator];
        [self animate:YES];
    }
    return self;
}

- (void)animate:(BOOL)animate {
    static CGFloat defaultUploadingIndicatorOriginX = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultUploadingIndicatorOriginX = self.uploadingIndicator.frame.origin.x;
    });
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
                     completion:nil];
}

@end
