//
//  SBReelViewController.m
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBClip.h"
#import "SBReelViewController.h"

@interface SBReelViewController ()

@end

@implementation SBReelViewController

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [SBClip getClipsWithSuccess:^{
    } failure:^(NSError *error) {
    }];
}

@end
