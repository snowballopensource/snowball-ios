//
//  SBCheckButton.m
//  Snowball
//
//  Created by James Martinez on 6/26/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCheckButton.h"

@implementation SBCheckButton

- (void)setParticipating:(BOOL)participating {
    if (participating) {
        [self setImage:[UIImage imageNamed:@"button-check-highlighted"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"button-check-normal"] forState:UIControlStateHighlighted];
    } else {
        // TODO: figure out a better asset for this, for now just switching assets
        // also, switch this if/else since the normal flow should be above (e.g. normal -> normal, etc.)
        [self setImage:[UIImage imageNamed:@"button-check-normal"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"button-check-highlighted"] forState:UIControlStateHighlighted];
    }
}

@end
