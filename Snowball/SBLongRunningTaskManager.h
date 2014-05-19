//
//  SBLongRunningTaskManager.h
//  Snowball
//
//  Created by James Martinez on 5/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBLongRunningTaskManager : NSObject

+ (void)addBlockToQueue:(void(^)(void))block;

@end
