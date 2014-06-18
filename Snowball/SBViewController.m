//
//  SBViewController.m
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBViewController.h"

@interface SBViewController ()

@end

@implementation SBViewController

+ (NSString *)identifier {
    return NSStringFromClass(self);
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // [self.navigationItem setLeftItemsSupplementBackButton:YES];

    [self setupBackButton];
}

#pragma mark - Actions

- (IBAction)dismissModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

- (void)setupBackButton {
    unless ([self.navigationController.viewControllers firstObject] == self) {
        UIImage *backButtonImage = [UIImage imageNamed:@"button-back-normal"] ;
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        UIImage *backButtonHighlightedImage = [UIImage imageNamed:@"button-back-highlighted"] ;
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonHighlightedImage forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:backButtonImage forState:UIControlStateNormal];
        [backButton setImage:backButtonHighlightedImage forState:UIControlStateHighlighted];
        [backButton setFrame:CGRectMake(0, 0, backButtonImage.size.width, backButtonImage.size.height)];
        [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barBackButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        [self.navigationItem setLeftBarButtonItem:barBackButton];
    }
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
