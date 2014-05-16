//
//  NSError+Snowball.h
//  Snowball
//
//  Created by James Martinez on 5/16/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString* const kSnowballAPIErrorType = @"SnowballAPIErrorType";
static NSString* const kSnowballAPIErrorMessage = @"SnowballAPIErrorMessage";

@interface NSError (Snowball)

- (NSString *)userAppropriateErrorMessage;

- (void)displayInView:(UIView *)view;

@end
