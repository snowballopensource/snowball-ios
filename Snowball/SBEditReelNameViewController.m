//
//  SBEditReelNameViewController.m
//  Snowball
//
//  Created by James Martinez on 9/1/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBEditReelNameViewController.h"
#import "SBReel.h"

@interface SBEditReelNameViewController ()

@property (nonatomic, weak) IBOutlet UITextField *reelNameTextField;

@end

@implementation SBEditReelNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.reelNameTextField setText:self.reel.name];
    [self.reelNameTextField setTextColor:self.reel.color];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.reelNameTextField becomeFirstResponder];
}

- (IBAction)save:(id)sender {
    [self showSpinner];
    [self.reel setName:self.reelNameTextField.text];
    [self.reel updateWithSuccess:^{
        [self hideSpinner];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        [self hideSpinner];
        [error displayInView:self.view];
    }];
}

@end
