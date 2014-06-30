//
//  SBEditProfileViewController.m
//  Snowball
//
//  Created by James Martinez on 6/30/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBEditProfileViewController.h"
#import "SBUser.h"
#import "SBUserImageView.h"

@interface SBEditProfileViewController ()

@property (nonatomic, weak) IBOutlet SBUserImageView *userImageView;

@end

@implementation SBEditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView setBackgroundColor:[UIColor whiteColor]];

    [self setBackButtonStyle:UIViewControllerBackButtonStyleDark];

    SBUser *user = [SBUser currentUser];
    [self.userImageView setImageWithURL:[NSURL URLWithString:user.avatarURL]
                       placeholderImage:[SBUserImageView placeholderImageWithInitials:user.name.initials withSize:self.userImageView.bounds.size]];
}

#pragma mark - UITableViewDataSource
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    // Return the number of rows in the section.
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - View Actions

- (IBAction)editProfileImage:(id)sender {
    [UIAlertView bk_showAlertViewWithTitle:@"Hello!" message:@"Haven't finished this yet. :)" cancelButtonTitle:@"Ok" otherButtonTitles:nil handler:nil];
}

- (IBAction)done:(id)sender {
    [UIAlertView bk_showAlertViewWithTitle:@"Hello!" message:@"Haven't finished this yet. :)" cancelButtonTitle:@"Ok" otherButtonTitles:nil handler:nil];
}

@end
