//
//  SBCameraViewController.m
//  Snowball
//
//  Created by James Martinez on 6/4/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCameraManager.h"
#import "SBCameraViewController.h"

@interface SBCameraViewController ()

@property (nonatomic, weak) IBOutlet UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@implementation SBCameraViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    SBCameraPreviewView *previewView = [SBCameraManager sharedManager].previewView;
    [previewView setFrame:self.view.frame];
    [self.view insertSubview:previewView atIndex:0];
    [self.view setAlpha:0.5];
}

#pragma mark - View Actions

- (IBAction)toggleCapture:(id)sender {
    if ([[SBCameraManager sharedManager] isRecording]) {
        [self.view setAlpha:0.5];
        [self.longPressGestureRecognizer setEnabled:FALSE];
        [[SBCameraManager sharedManager] stopRecordingWithCompletion:^(NSURL *fileURL) {
            [self.longPressGestureRecognizer setEnabled:TRUE];
            if (self.recordingCompletionBlock) self.recordingCompletionBlock(fileURL);
        }];
    } else {
        [self.view setAlpha:1.0];
        [[SBCameraManager sharedManager] startRecording];
    }
}

@end
