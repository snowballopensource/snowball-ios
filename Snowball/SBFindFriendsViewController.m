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

@interface SBFindFriendsViewController () <SBUserTableViewCellDelegate>

@property (nonatomic, strong) NSArray *users;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation SBFindFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [SBUserTableViewCell registerNibToTableView:self.tableView];

    if ([SBAddressBookManager authorized]) {
        [self showSpinner];
        [self getContactsFromAddressBook];
    } else {
        [self.tableView setHidden:YES];
    }
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
    [cell setDelegate:self];
    SBUser *user = self.users[indexPath.row];
    [cell.nameLabel setText:user.name];
    [cell.userImageView setImageWithURL:[NSURL URLWithString:user.avatarURL]
                       placeholderImage:[SBUserImageView placeholderImageWithInitials:[user.name initials] withSize:cell.userImageView.frame.size]];
    if (user == [SBUser currentUser]) {
        [cell setStyle:SBUserTableViewCellStyleNone];
    } else {
        [cell setStyle:SBUserTableViewCellStyleFollowable];
        [cell.followButton setFollowing:user.followingValue];
    }
}

#pragma mark - SBUserTableViewCellDelegate

- (void)followUserButtonPressedInCell:(SBUserTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SBUser *user = self.users[indexPath.row];
    [cell.followButton setFollowing:!user.followingValue];
    if (user.followingValue) {
        [user unfollowWithSuccess:nil failure:nil];
    } else {
        [user followWithSuccess:nil failure:nil];
    }
}

#pragma mark - Actions

- (IBAction)findFriendsViaContacts:(id)sender {
    [self showSpinner];
    [self getContactsFromAddressBook];
}

#pragma mark - Private

- (void)getContactsFromAddressBook {
    [SBAddressBookManager getAllPhoneNumbersWithCompletion:^(NSArray *phoneNumbers) {
        if ([phoneNumbers count] > 0) {
            [SBUser findUsersByPhoneNumbers:phoneNumbers
                                       page:0  // TODO: make this paginated
                                    success:^(NSArray *users) {
                                        [self setUsers:users];
                                        [self hideSpinner];
                                        [self showTableView];
                                    } failure:^(NSError *error) {
                                        [self hideSpinner];
                                        [error displayInView:self.view];
                                    }];
        } else {
            [self hideSpinner];
        }
    }];
}

- (void)showTableView {
    [self.tableView setHidden:NO];
    [self.tableView reloadData];
}

@end
