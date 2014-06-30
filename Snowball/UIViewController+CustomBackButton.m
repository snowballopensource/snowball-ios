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
        UIImage *backButtonImage = nil;
        switch (style) {
            case UIViewControllerBackButtonStyleDark:
                backButtonImage = [UIImage imageNamed:@"button-back-black-normal"];
                break;
            default:
                backButtonImage = [UIImage imageNamed:@"button-back-normal"] ;
                break;
        }
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

#pragma mark - Private

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
