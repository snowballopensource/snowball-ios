//
//  SBLongRunningTaskManager.m
//  Snowball
//
//  Created by James Martinez on 5/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBLongRunningTaskManager.h"

@interface SBLongRunningTaskManager ()

@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation SBLongRunningTaskManager

#pragma mark - Singleton

+ (instancetype)sharedManager {
    static SBLongRunningTaskManager* sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [SBLongRunningTaskManager new];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("com.snowball.snowball.longtaskqueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - Adding to Queue

+ (void)addBlockToQueue:(void(^)(void))block {
    dispatch_async([SBLongRunningTaskManager sharedManager].queue, ^{
        block();
    });
}

@end
