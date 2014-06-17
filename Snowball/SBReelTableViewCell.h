//
//  SBReelTableViewCell.h
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBTableViewCell.h"

@interface SBReelTableViewCell : SBTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *participantOneImageView;
@property (nonatomic, weak) IBOutlet UIImageView *participantTwoImageView;
@property (nonatomic, weak) IBOutlet UIImageView *participantThreeImageView;
@property (nonatomic, weak) IBOutlet UIImageView *participantFourImageView;
@property (nonatomic, weak) IBOutlet UIImageView *participantFiveImageView;


@end
