//
//  SBUserTableViewCell.m
//  Snowball
//
//  Created by James Martinez on 6/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBReel.h"
#import "SBUser.h"
#import "SBUserTableViewCell.h"

@interface SBUserTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet SBUserImageView *userImageView;
@property (nonatomic, weak) IBOutlet SBUserAddButton *addButton;

@property (nonatomic, weak) id<SBUserTableViewCellDelegate> delegate;

@end

@implementation SBUserTableViewCell

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    
    [self.nameLabel setTextColor:tintColor];
    [self.addButton setImageTintColor:tintColor];
}

#pragma mark - SBTableViewCell

- (void)configureForObject:(id)object {
    NSAssert(false, @"Use -configureForObject:delegate: instead of -configureForObject:");
}

- (void)configureForObject:(id)object delegate:(id<SBUserTableViewCellDelegate>)delegate {
    SBUser *user = (SBUser *)object;
    
    [self setDelegate:delegate];
    [self.nameLabel setText:user.name];
    [self.userImageView setImageWithURL:[NSURL URLWithString:user.avatarURL]
                       placeholderImage:[SBUserImageView placeholderImageWithInitials:[user.name initials] withSize:self.userImageView.frame.size]];

    UIColor *color = user.color;
    if (user == [SBUser currentUser]) {
        [self setStyle:SBUserTableViewCellStyleNone];
        color = [UIColor snowballColorBlue];

    } else {
        [self setStyle:SBUserTableViewCellStyleSelectable];
        [self setChecked:user.followingValue];
    }
    [self setTintColor:color];
}

#pragma mark - Actions

- (IBAction)cellSelected:(id)sender {
    if ([self.delegate respondsToSelector:@selector(userCellSelected:)]) {
        [self.delegate userCellSelected:self];
    }
}

#pragma mark - Setters / Getters

- (void)setStyle:(SBUserTableViewCellStyle)style {
    switch (style) {
        case SBUserTableViewCellStyleSelectable:
            [self.addButton setHidden:NO];
            break;
        default:
            [self.addButton setHidden:YES];
            break;
    }
}

- (void)setChecked:(BOOL)checked {
    [self.addButton setChecked:checked];
}

@end
