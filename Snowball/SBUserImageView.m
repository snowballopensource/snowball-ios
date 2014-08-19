//
//  SBUserImageView.m
//  Snowball
//
//  Created by James Martinez on 6/9/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBUser.h"
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

#pragma mark - Placeholder Image View

- (void)setImageWithUser:(SBUser *)user {
    UIImage *image = [SBUserImageView placeholderImageWithInitials:[user initials] withSize:self.frame.size backgroundColor:user.color];
    [super setImageWithURL:[NSURL URLWithString:user.avatarURL] placeholderImage:image];
}

#pragma mark - Private

+ (UIImage *)placeholderImageWithInitials:(NSString *)initials withSize:(CGSize)size backgroundColor:(UIColor *)backgroundColor {
    UIView *placeholderView = [[self alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [placeholderView setBackgroundColor:backgroundColor];
    UILabel *initialsLabel = [[UILabel alloc] initWithFrame:placeholderView.bounds];
    [initialsLabel setTextColor:[UIColor whiteColor]];
    [initialsLabel setTextAlignment:NSTextAlignmentCenter];
    [initialsLabel setText:initials];
    [initialsLabel setFont:[UIFont fontWithName:[UIFont snowballFontNameMedium] size:initialsLabel.font.pointSize]];
    [placeholderView addSubview:initialsLabel];
    return [placeholderView imageRepresentation];
}

@end
