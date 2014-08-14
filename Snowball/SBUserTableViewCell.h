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

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet SBUserImageView *userImageView;
@property (nonatomic, weak) IBOutlet SBUserAddButton *addButton;

@property (nonatomic, weak) id<SBUserTableViewCellDelegate> delegate;

- (void)setStyle:(SBUserTableViewCellStyle)style;

@end
