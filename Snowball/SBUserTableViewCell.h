//
//  SBUserTableViewCell.h
//  Snowball
//
//  Created by James Martinez on 6/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBFollowButton.h"
#import "SBTableViewCell.h"
#import "SBUserImageView.h"

@interface SBUserTableViewCell : SBTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet SBUserImageView *userImageView;
@property (nonatomic, weak) IBOutlet SBFollowButton *followButton;

@end
