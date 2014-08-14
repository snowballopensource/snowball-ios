//
//  UIViewController+BackButton.m
//  Snowball
//
//  Created by James Martinez on 8/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "UIViewController+BackButton.h"

@implementation UIViewController (BackButton)

- (void)setupBackButton {
    unless ([self.navigationController.viewControllers firstObject] == self) {
        UIImage *backButtonImage = [UIImage imageNamed:@"top-back"];

        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:backButtonImage forState:UIControlStateNormal];
        [backButton setFrame:CGRectMake(0, 0, backButtonImage.size.width, backButtonImage.size.height)];
        [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];

        [backButton setImageTintColor:[UIColor whiteColor]];
        
        UIBarButtonItem *barBackButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        [self.navigationItem setLeftBarButtonItem:barBackButton];
    }
}

#pragma mark - Private

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
