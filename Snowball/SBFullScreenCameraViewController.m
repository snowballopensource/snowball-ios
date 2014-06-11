//
//  SBFullScreenCameraViewController.m
//  Snowball
//
//  Created by James Martinez on 6/10/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCameraViewController.h"
#import "SBFullScreenCameraViewController.h"
#import "SBReel.h"

@interface SBFullScreenCameraViewController ()

@end

@implementation SBFullScreenCameraViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[SBCameraViewController class]]) {
        [(SBCameraViewController *)segue.destinationViewController setRecordingCompletionBlock:^(NSURL *fileURL) {
            NSLog(@"Recording completed @ %@", [fileURL path]);
            // TODO: upload video
            // If reel, upload to reel
            // else, show options to create new reel
            if (self.reel) {

            } else {

            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

@end
