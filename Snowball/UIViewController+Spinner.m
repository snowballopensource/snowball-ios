//
//  UIViewController+Spinner.m
//  Snowball
//
//  Created by James Martinez on 5/20/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "UIViewController+Spinner.h"

@implementation UIViewController (Spinner)

- (void)showSpinner {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)hideSpinner {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

@end
