//
//  SBMainMenuViewController.m
//  Snowball
//
//  Created by James Martinez on 5/16/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBMainMenuViewController.h"
#import "SBSessionManager.h"

@interface SBMainMenuViewController () <UITableViewDelegate>

@end

@implementation SBMainMenuViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor whiteColor]];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [SBSessionManager signOut];
    }
}

#pragma mark - ECSlidingViewController

- (IBAction)unwindToMenuViewController:(UIStoryboardSegue *)segue {}

@end
