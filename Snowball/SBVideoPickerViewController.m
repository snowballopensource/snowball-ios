//
//  SBVideoPickerViewController.m
//  Snowball
//
//  Created by James Martinez on 5/29/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCameraManager.h"
#import "SBFullScreenCameraView.h"
#import "SBVideoPickerViewController.h"

@interface SBVideoPickerViewController ()

@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic) BOOL isCapturing;

@end

@implementation SBVideoPickerViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [(SBFullScreenCameraView *)self.view startCamera];
}

#pragma mark - Actions

//    [SBVideoPickerController launchCameraInView:self.view
//                                         sender:self
//                                     completion:^(NSData *videoData, NSURL *videoLocalURL) {
//                                         [SBLongRunningTaskManager addBlockToQueue:^{
//                                             SBClip *clip = [SBClip MR_createEntity];
//                                             [clip setReel:[self.reel MR_inContext:clip.managedObjectContext]];
//                                             [clip setVideoToSubmit:videoData];
//                                             [clip save];
//                                             [clip create];
//                                         }];
//                                         [self playLocalVideoImmediately:videoLocalURL];
//                                     }];

- (IBAction)captureVideo:(id)sender {
    // TODO: change this file path
    GPUImageVideoCamera *videoCamera = [SBCameraManager sharedManager].videoCamera;
    NSURL *movieFileURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"]];
    if (self.isCapturing) {
        [videoCamera setAudioEncodingTarget:nil];
        [self.movieWriter finishRecording];
        self.videoCaptureCompleteBlock([NSData dataWithContentsOfURL:movieFileURL]);
    } else {
        [self setMovieWriter:[[GPUImageMovieWriter alloc] initWithMovieURL:movieFileURL size:CGSizeMake(960, 540)]];
        [self.movieWriter setEncodingLiveVideo:YES];
        [videoCamera addTarget:self.movieWriter];
        [videoCamera setAudioEncodingTarget:self.movieWriter];
        [videoCamera startCameraCapture];
        [self.movieWriter startRecording];
    }
    [self setIsCapturing:!self.isCapturing];
}

- (IBAction)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
