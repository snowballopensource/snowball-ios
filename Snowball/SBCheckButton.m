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
    [self setHidden:!participating];
}

@end
