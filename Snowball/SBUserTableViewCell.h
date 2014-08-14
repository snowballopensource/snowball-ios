//
//  SBUserTableViewCell.h
//  Snowball
//
//  Created by James Martinez on 6/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBTableViewCell.h"
#import "SBUserImageView.h"
#import "SBUserAddButton.h"

@class SBUserTableViewCell;

@protocol SBUserTableViewCellDelegate <NSObject>

@optional

- (void)userCellSelected:(SBUserTableViewCell *)cell;

@end

@interface SBUserTableViewCell : SBTableViewCell

typedef NS_ENUM(NSInteger, SBUserTableViewCellStyle) {
    SBUserTableViewCellStyleNone,
    SBUserTableViewCellStyleSelectable
};

- (void)setStyle:(SBUserTableViewCellStyle)style;
- (void)setChecked:(BOOL)checked;

- (void)configureForObject:(id)object delegate:(id<SBUserTableViewCellDelegate>)delegate;

@end
