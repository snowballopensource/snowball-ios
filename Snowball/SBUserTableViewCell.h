//
//  SBUserTableViewCell.h
//  Snowball
//
//  Created by James Martinez on 6/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBFollowButton.h"
#import "SBTableViewCell.h"

@interface SBUserTableViewCell : SBTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet SBFollowButton *followButton;

@end
