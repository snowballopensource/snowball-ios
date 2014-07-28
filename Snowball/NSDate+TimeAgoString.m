//
//  NSDate+TimeAgoString.m
//  Snowball
//
//  Created by James Martinez on 7/28/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "NSDate+TimeAgoString.h"

@implementation NSDate (TimeAgoString)

- (NSString *)shortTimeAgoString {
    NSDate *now = [NSDate date];
    double deltaSeconds = fabs([self timeIntervalSinceDate:now]);
    double deltaMinutes = deltaSeconds / 60.0f;
    int value;
    
    if(deltaSeconds < 60) {
        return [NSString stringWithFormat:@"%ds", (int)floor(deltaSeconds)];
    }
    else if (deltaMinutes < 60) {
        return [NSString stringWithFormat:@"%dm", (int)floor(deltaMinutes)];
    }
    else if (deltaMinutes < (24 * 60)) {
        value = (int)floor(deltaMinutes/60);
        return [NSString stringWithFormat:@"%dh", value];
    }
    else if (deltaMinutes < (24 * 60 * 7)) {
        value = (int)floor(deltaMinutes/(60 * 24));
        return [NSString stringWithFormat:@"%dd", value];
    }
    else if (deltaMinutes < (24 * 60 * 31)) {
        value = (int)floor(deltaMinutes/(60 * 24 * 7));
        return [NSString stringWithFormat:@"%dw", value];
    }
    else if (deltaMinutes < (24 * 60 * 365.25)) {
        value = (int)floor(deltaMinutes/(60 * 24 * 30));
        return [NSString stringWithFormat:@"%dmo", value];
    } else {
        value = (int)floor(deltaMinutes/(60 * 24 * 365));
        return [NSString stringWithFormat:@"%dyr", value];
    }
}

@end
