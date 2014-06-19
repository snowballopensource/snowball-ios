//
//  SBCameraManager.m
//  Snowball
//
//  Created by James Martinez on 5/28/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCameraManager.h"

@implementation SBCameraPreviewView

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)captureSession {
    return [(AVCaptureVideoPreviewLayer *)[self layer] session];
}

- (void)setCaptureSession:(AVCaptureSession *)captureSession {
    [(AVCaptureVideoPreviewLayer *)[self layer] setSession:captureSession];
}

@end

#import <AssetsLibrary/AssetsLibrary.h>

@interface SBCameraManager () <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) dispatch_queue_t captureSessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic, strong) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, strong) id runtimeErrorHandlingObserver;
@property (nonatomic, copy) void(^recordingCompletionBlock)(NSURL *fileURL);

@property (nonatomic, strong) AVAssetExportSession *exporter;

@end

@implementation SBCameraManager

#pragma mark - Initialization

+ (instancetype)sharedManager {
    static SBCameraManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [SBCameraManager new];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeCamera];
    }
    return self;
}

#pragma mark - Private

- (void)initializeCamera {
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    [self setCaptureSession:captureSession];

    [self createPreviewView];
    [self.previewView setCaptureSession:captureSession];

    [self checkDeviceAuthorizationStatus];
    
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
    dispatch_queue_t captureSessionQueue = dispatch_queue_create("captureSessionQueue", DISPATCH_QUEUE_SERIAL);
    [self setCaptureSessionQueue:captureSessionQueue];
    
    dispatch_async(captureSessionQueue, ^{
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [SBCameraManager deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error) NSLog(@"%@", error);
        
        if ([captureSession canAddInput:videoDeviceInput]) {
            [captureSession addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        }
        
        AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if (error) NSLog(@"%@", error);
        
        if ([captureSession canAddInput:audioDeviceInput]) {
            [captureSession addInput:audioDeviceInput];
        }
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([captureSession canAddOutput:movieFileOutput]) {
            [captureSession addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoStabilizationSupported])
                [connection setEnablesVideoStabilizationWhenAvailable:YES];
            [self setMovieFileOutput:movieFileOutput];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        
        __weak SBCameraManager *weakSelf = self;
        [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self captureSession] queue:nil usingBlock:^(NSNotification *note) {
            SBCameraManager *strongSelf = weakSelf;
            dispatch_async([strongSelf captureSessionQueue], ^{
                // Manually restarting the session since it must have been stopped due to an error.
                [[strongSelf captureSession] startRunning];
            });
        }]];
        [[self captureSession] startRunning];
    });
}

- (void)createPreviewView {
    [self setPreviewView:[SBCameraPreviewView new]];
    [(AVCaptureVideoPreviewLayer*)self.previewView.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

// TODO: this needs to be implemented somewhere
- (void)stopCamera {
    dispatch_async([self captureSessionQueue], ^{
        [[self captureSession] stopRunning];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
    });
}

- (void)subjectAreaDidChange:(NSNotification *)notification {
    CGPoint devicePoint = CGPointMake(.5, .5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    dispatch_async([self captureSessionQueue], ^{
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode]) {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode]) {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else {
            NSLog(@"%@", error);
        }
    });
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device {
    if ([device hasFlash] && [device isFlashModeSupported:flashMode]) {
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else {
            NSLog(@"%@", error);
        }
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

- (void)checkDeviceAuthorizationStatus {
    NSString *mediaType = AVMediaTypeVideo;
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted) {
            [self setDeviceAuthorized:YES];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setDeviceAuthorized:NO];
                [UIAlertView bk_alertViewWithTitle:@"Camera Error!" message:@"You denied access to the camera. To re-enable access, go to your privacy settings."];
            });
        }
    }];
}

#pragma mark - Public

- (void)startRecording {
    dispatch_async([self captureSessionQueue], ^{
        if ([[UIDevice currentDevice] isMultitaskingSupported]) {
            // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until the app returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
            [self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
        }
        
        // Turning OFF flash for video recording
        [SBCameraManager setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
        
        // Start recording to a temporary file.
        NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
        NSURL *outputFileURL = [NSURL fileURLWithPath:outputFilePath];
        // Remove previous file if one exists.
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        [[self movieFileOutput] startRecordingToOutputFileURL:outputFileURL recordingDelegate:self];
    });
}

- (void)stopRecordingWithCompletion:(void(^)(NSURL *fileURL))completion {
    [self setRecordingCompletionBlock:completion];
    dispatch_async(self.captureSessionQueue, ^{
        [[self movieFileOutput] stopRecording];
    });
}

- (BOOL)isRecording {
    return [self.movieFileOutput isRecording];
}

- (void)changeCamera {
    dispatch_async([self captureSessionQueue], ^{
        AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        
        switch ([currentVideoDevice position]) {
            case AVCaptureDevicePositionUnspecified:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
        }
        
        AVCaptureDevice *videoDevice = [SBCameraManager deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        
        [[self captureSession] beginConfiguration];
        
        [[self captureSession] removeInput:[self videoDeviceInput]];
        if ([[self captureSession] canAddInput:videoDeviceInput]) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
            
            [SBCameraManager setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
            
            [[self captureSession] addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        }
        else {
            [[self captureSession] addInput:[self videoDeviceInput]];
        }
        
        [[self captureSession] commitConfiguration];
    });
}

- (void)focusAndExposePoint:(CGPoint)point {
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:point monitorSubjectAreaChange:YES];
}

#pragma mark AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    
    if (error) NSLog(@"%@", error);
    
    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
    UIBackgroundTaskIdentifier backgroundRecordingID = self.backgroundRecordingID;
    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];

    [self cropVideoAtURL:outputFileURL completion:^(NSURL *croppedFileURL) {
        [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:croppedFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) NSLog(@"%@", error);
            
            if (backgroundRecordingID != UIBackgroundTaskInvalid)
                [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.recordingCompletionBlock) self.recordingCompletionBlock(croppedFileURL);
            });
        }];
    }];
}

- (void)cropVideoAtURL:(NSURL *)fileURL completion:(void(^)(NSURL *croppedFileURL))completion; {
    // Crop video, then save to album.
    // http://stackoverflow.com/a/5231713/801858
    AVAsset *asset = [AVAsset assetWithURL:fileURL];
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];

    // When thinking about the following code, think of capturing video in landscape!
    // e.g. videoTrack.naturalSize.height is the width if you are holding the phone portrait
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    [videoComposition setRenderSize:CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.height)];
    [videoComposition setFrameDuration:CMTimeMake(1, 30)];
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    [instruction setTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))];
    
    AVMutableVideoCompositionLayerInstruction *transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    // Crop to middle of the view
    // http://www.one-dreamer.com/cropping-video-square-like-vine-instagram-xcode/
    
    CGAffineTransform initialTransform = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, -(videoTrack.naturalSize.width - videoTrack.naturalSize.height) /2 );
    CGAffineTransform transform = CGAffineTransformRotate(initialTransform, M_PI_2);

    [transformer setTransform:transform atTime:kCMTimeZero];
    [instruction setLayerInstructions:@[transformer]];
    [videoComposition setInstructions:@[instruction]];
    
    NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie_cropped" stringByAppendingPathExtension:@"mov"]];
    NSURL *outputFileURL = [NSURL fileURLWithPath:outputFilePath];
    // Remove previous file if one exists.
    [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
    
    //Export
    [self setExporter:[[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality]];
    [self.exporter setVideoComposition:videoComposition];
    [self.exporter setOutputURL:outputFileURL];
    [self.exporter setOutputFileType:AVFileTypeMPEG4];
    [self.exporter exportAsynchronouslyWithCompletionHandler:^{
        completion(self.exporter.outputURL);
    }];
}

@end
