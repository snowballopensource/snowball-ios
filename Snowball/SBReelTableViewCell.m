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

// FOCUS ON:
// disclosure
// addClip

- (void)setState:(SBReelTableViewCellState)state animated:(BOOL)animated {
    switch (state) {
        case SBReelTableViewCellStatePendingUpload: {
            [self.addClipIndicator setHidden:NO];
            if (animated) {
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     [self.disclosureIndicator setCenter:CGPointMake(self.disclosureIndicator.center.x+100, self.disclosureIndicator.center.y)];
                                     [self.hasNewClipIndicator setCenter:CGPointMake(self.hasNewClipIndicator.center.x+100, self.hasNewClipIndicator.center.y)];
                                     [self.addClipIndicator setCenter:CGPointMake(self.addClipIndicator.center.x-100, self.addClipIndicator.center.y)];
                                 }];
            } else {
                [self.disclosureIndicator setHidden:YES];
                [self.hasNewClipIndicator setHidden:YES];
            }
        }
            break;
        default: {
            if (animated) {
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     [self.disclosureIndicator setCenter:CGPointMake(self.disclosureIndicator.center.x-100, self.disclosureIndicator.center.y)];
                                     [self.hasNewClipIndicator setCenter:CGPointMake(self.hasNewClipIndicator.center.x-100, self.hasNewClipIndicator.center.y)];
                                     [self.addClipIndicator setCenter:CGPointMake(self.addClipIndicator.center.x+100, self.addClipIndicator.center.y)];
                                 } completion:^(BOOL finished) {
                                     [self.addClipIndicator setHidden:YES];
                                 }];
            } else {
                [self.addClipIndicator setHidden:YES];
                [self setShowsNewClipIndicator:_showsNewClipIndicator];
            }
        }
            break;
    }
    _state = state;
}

@end
