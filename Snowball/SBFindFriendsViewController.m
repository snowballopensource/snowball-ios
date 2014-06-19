//
//  SBFindFriendsViewController.m
//  Snowball
//
//  Created by James Martinez on 6/19/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBAddressBookManager.h"
#import "SBFindFriendsViewController.h"
#import "SBUser.h"
#import "SBUserTableViewCell.h"

@interface SBFindFriendsViewController ()

@property (nonatomic, strong) NSArray *users;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation SBFindFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [SBUserTableViewCell registerNibToTableView:self.tableView];

    [self.tableView setHidden:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SBUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SBUserTableViewCell identifier] forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(SBUserTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SBUser *user = self.users[indexPath.row];
    [cell.nameLabel setText:user.name];
    [cell.userImageView setImageWithURL:[NSURL URLWithString:user.avatarURL]];
}

#pragma mark - Actions

- (IBAction)findFriendsViaContacts:(id)sender {
    [self showSpinner];
    [SBAddressBookManager getAllPhoneNumbersWithCompletion:^(NSArray *phoneNumbers) {
        [SBUser findUsersByPhoneNumbers:phoneNumbers
                                   page:0  // TODO: make this paginated
                                success:^(NSArray *users) {
                                    [self setUsers:users];
                                    [self hideSpinner];
                                    [self.tableView setHidden:NO];
                                    [self.tableView reloadData];
                                } failure:^(NSError *error) {
                                    [error displayInView:self.view];
                                }];
    }];
}

@end
