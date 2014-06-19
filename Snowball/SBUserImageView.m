//
//  SBUserImageView.m
//  Snowball
//
//  Created by James Martinez on 6/9/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBUserImageView.h"

@implementation SBUserImageView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self.layer setCornerRadius:(self.frame.size.width/2)];
        [self setClipsToBounds:YES];
    }
    return self;
}

#pragma mark - Placeholder Image

+ (UIImage *)placeholderImageWithInitials:(NSString *)initials withSize:(CGSize)size {
    UIView *placeholderView = [[self alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [placeholderView setBackgroundColor:[UIColor lightGrayColor]];
    UILabel *initialsLabel = [[UILabel alloc] initWithFrame:placeholderView.bounds];
    [initialsLabel setTextColor:[UIColor whiteColor]];
    [initialsLabel setTextAlignment:NSTextAlignmentCenter];
    [initialsLabel setText:initials];
    [placeholderView addSubview:initialsLabel];
    return [placeholderView imageRepresentation];
}

@end
