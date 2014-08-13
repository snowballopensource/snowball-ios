//
//  UIViewController+CustomBackButton.m
//  Snowball
//
//  Created by James Martinez on 6/30/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "UIViewController+CustomBackButton.h"

@implementation UIViewController (CustomBackButton)

- (void)setBackButtonStyle:(UIViewControllerBackButtonStyle)style {
    unless ([self.navigationController.viewControllers firstObject] == self) {
        UIImage *backButtonImage = [UIImage imageNamed:@"button-back-normal"];

        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:backButtonImage forState:UIControlStateNormal];
        [backButton setFrame:CGRectMake(0, 0, backButtonImage.size.width, backButtonImage.size.height)];
        [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];

        // TODO: remove this when done removing all dark bar buttons
        switch (style) {
            case UIViewControllerBackButtonStyleDark:
                [backButton setImageTintColor:[UIColor blackColor]];
                break;
            default:
                [backButton setImageTintColor:[UIColor whiteColor]];
                break;
        }

        UIBarButtonItem *barBackButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        [self.navigationItem setLeftBarButtonItem:barBackButton];
    }
}

#pragma mark - Private

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
