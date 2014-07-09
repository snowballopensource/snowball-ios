//
//  SBReelTableViewCell.m
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBReelTableViewCell.h"

@interface SBReelTableViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *disclosureIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *hasNewClipIndicator;

@end

@implementation SBReelTableViewCell

- (void)setShowsNewClipIndicator:(BOOL)showsNewClipIndicator {
    [self.hasNewClipIndicator setHidden:!showsNewClipIndicator];
    [self.disclosureIndicator setHidden:showsNewClipIndicator];
}

@end
