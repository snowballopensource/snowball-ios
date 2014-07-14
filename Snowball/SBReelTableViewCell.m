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
@property (nonatomic, weak) IBOutlet UIImageView *addClipIndicator;

@property (nonatomic) SBReelTableViewCellState state;

@end

@implementation SBReelTableViewCell

- (void)setShowsNewClipIndicator:(BOOL)showsNewClipIndicator {
    [self.hasNewClipIndicator setHidden:!showsNewClipIndicator];
    [self.disclosureIndicator setHidden:showsNewClipIndicator];
    _showsNewClipIndicator = showsNewClipIndicator;
}

- (void)setState:(SBReelTableViewCellState)state animated:(BOOL)animated {
    switch (state) {
        case SBReelTableViewCellStatePendingUpload:
            [self.disclosureIndicator setHidden:YES];
            [self.hasNewClipIndicator setHidden:YES];
            [self.addClipIndicator setHidden:NO];
            break;
        default:
            [self.addClipIndicator setHidden:YES];
            break;
    }
    _state = state;
}

@end
