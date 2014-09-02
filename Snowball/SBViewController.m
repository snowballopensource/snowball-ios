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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBackButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.navBarColor && self.navigationController.navigationBar.barTintColor != self.navBarColor) {
        [self.navigationController.navigationBar setTranslucent:NO];
        [self.navigationController.navigationBar setBarTintColor:self.navBarColor];
    }
}

#pragma mark - Actions

- (IBAction)dismissModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

// If the child VC is a table view controller, these methods will be used
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        if (self.navigationController.navigationBar.barTintColor) {
            UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
            [headerView.textLabel setTextColor:self.navigationController.navigationBar.barTintColor];
        }
    }
}

@end
