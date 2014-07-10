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
}

#pragma mark - View Actions

- (IBAction)toggleCapture:(id)sender {
    if ([[SBCameraManager sharedManager] isRecording]) {
        [self.longPressGestureRecognizer setEnabled:FALSE];
        [self showSpinner];
        [[SBCameraManager sharedManager] stopRecordingWithCompletion:^(NSURL *fileURL) {
            [self hideSpinner];
            [self.longPressGestureRecognizer setEnabled:TRUE];
            if (self.recordingCompletionBlock) self.recordingCompletionBlock(fileURL);
        }];
    } else {
        [[SBCameraManager sharedManager] startRecording];
    }
}

- (IBAction)flipCamera:(id)sender {
    NSLog(@"Flip camera.");
}

@end
