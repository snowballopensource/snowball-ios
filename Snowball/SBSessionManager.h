//
//  SBSessionManager.h
//  Snowball
//
//  Created by James Martinez on 5/14/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBSessionManager : NSObject

+ (void)startSession;
+ (void)signOut;

+ (NSDate *)sessionDate;

@end