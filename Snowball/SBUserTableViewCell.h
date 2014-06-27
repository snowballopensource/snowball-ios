//
//  SBUserTableViewCell.h
//  Snowball
//
//  Created by James Martinez on 6/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCheckButton.h"
#import "SBFollowButton.h"
#import "SBTableViewCell.h"
#import "SBUserImageView.h"

@class SBUserTableViewCell;

@protocol SBUserTableViewCellDelegate <NSObject>

@optional

- (void)followUserButtonPressedInCell:(SBUserTableViewCell *)cell;
- (void)checkUserButtonPressedInCell:(SBUserTableViewCell *)cell;

@end

@interface SBUserTableViewCell : SBTableViewCell

typedef NS_ENUM(NSInteger, SBUserTableViewCellStyle) {
    SBUserTableViewCellStyleNone,
    SBUserTableViewCellStyleFollowable,
    SBUserTableViewCellStyleSelectable
};

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet SBUserImageView *userImageView;
@property (nonatomic, weak) IBOutlet SBFollowButton *followButton;
@property (nonatomic, weak) IBOutlet SBCheckButton *checkButton;

@property (nonatomic, weak) id<SBUserTableViewCellDelegate> delegate;

- (void)setStyle:(SBUserTableViewCellStyle)style;

@end
