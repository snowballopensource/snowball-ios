//
//  SBCameraManager.h
//  Snowball
//
//  Created by James Martinez on 5/28/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBCameraManager : NSObject

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;

+ (instancetype)sharedManager;

@end
