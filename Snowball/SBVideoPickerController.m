//
//  SBVideoPickerController.m
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBVideoPickerController.h"

@interface SBVideoPickerController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, copy) void(^completionBlock)(NSData *videoData);

@end

@implementation SBVideoPickerController

+ (void)launchCameraInView:(UIView *)view sender:(id)sender completion:(void(^)(NSData *videoData))completion {
    SBVideoPickerController *videoPickerController = [SBVideoPickerController new];
    [videoPickerController setCompletionBlock:completion];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [videoPickerController launchImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary sender:sender];
        return;
    }
    
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:nil];
    [actionSheet bk_addButtonWithTitle:@"Take a Video..." handler:^{
        [videoPickerController launchImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera sender:sender];
    }];
    [actionSheet bk_addButtonWithTitle:@"Choose a Video..." handler:^{
        [videoPickerController launchImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary sender:sender];
    }];
    [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    [actionSheet showInView:view];
}

- (void)launchImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
                                 sender:(id)sender {
    [self setDelegate:self];
    [self setSourceType:sourceType];
    [self setAllowsEditing:YES];
    [self setMediaTypes:@[(NSString *)kUTTypeMovie]];
    [sender presentViewController:self animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *videoURL = info[UIImagePickerControllerMediaURL];
    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    [picker dismissViewControllerAnimated:YES completion:^{
        self.completionBlock(videoData);
    }];
}

@end
