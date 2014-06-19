//
//  NSString+Initials.m
//  Snowball
//
//  Created by James Martinez on 6/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "NSString+Initials.h"

@implementation NSString (Initials)

- (NSString *)initials {
    NSArray *names = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    names = [names filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    NSMutableArray *initials = [@[] mutableCopy];
    for (NSString *name in names) {
        [initials addObject:[name substringToIndex:1]];
    }
    NSString *initialsString = [[initials componentsJoinedByString:@""] uppercaseString];
    return initialsString;
}

@end
