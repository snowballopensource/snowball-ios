//
//  SBFullScreenCameraViewController.m
//  Snowball
//
//  Created by James Martinez on 6/10/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCameraViewController.h"
#import "SBClip.h"
#import "SBCreateReelViewController.h"
#import "SBFullScreenCameraViewController.h"
#import "SBLongRunningTaskManager.h"
#import "SBReel.h"

@interface SBFullScreenCameraViewController ()

@end

@implementation SBFullScreenCameraViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[SBCameraViewController class]]) {
        [(SBCameraViewController *)segue.destinationViewController setRecordingCompletionBlock:^(NSURL *fileURL) {
            // This is semi duplicated code since clips are uploaded in three places.
            SBClip *clip = [SBClip MR_createEntity];
            [clip setReel:self.reel];
            NSData *data = [NSData dataWithContentsOfURL:fileURL];
            [clip setVideoToSubmit:data];
            [clip save];
            [SBLongRunningTaskManager addBlockToQueue:^{
                [clip create];
            }];
            if (self.recordingCompletionBlock) self.recordingCompletionBlock(fileURL);
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

@end
