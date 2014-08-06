//
//  SBReelTableViewCell.h
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBTableViewCell.h"

typedef NS_ENUM(NSInteger, SBReelTableViewCellState) {
    SBReelTableViewCellStateNormal,
    SBReelTableViewCellStateHasNewClip,
    SBReelTableViewCellStatePlaying,
    SBReelTableViewCellStateAddClip,
    SBReelTableViewCellStateUploading
};

@interface SBReelTableViewCell : SBTableViewCell

- (void)configureForObject:(id)object state:(SBReelTableViewCellState)state;

- (void)setState:(SBReelTableViewCellState)state animated:(BOOL)animated;

@end
