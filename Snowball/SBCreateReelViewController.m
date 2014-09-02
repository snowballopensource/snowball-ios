//
//  SBCreateReelViewController.m
//  Snowball
//
//  Created by James Martinez on 6/4/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBCreateReelViewController.h"
#import "SBClip.h"
#import "SBFindFriendsViewController.h"
#import "SBLongRunningTaskManager.h"
#import "SBPlayerView.h"
#import "SBTextFieldTableViewCell.h"
#import "SBUserTableViewCell.h"
#import "SBReel.h"
#import "SBUser.h"

typedef NS_ENUM(NSInteger, SBCreateReelTableViewSection) {
    SBCreateReelTableViewSectionName,
    SBCreateReelTableViewSectionParticipants
};

@interface SBCreateReelViewController () <SBUserTableViewCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet SBPlayerView *playerView;
@property (nonatomic, weak) IBOutlet UIButton *finishButton;
@property (nonatomic, weak) IBOutlet UILabel *createNewGroupLabel;

@property (nonatomic, copy) NSSet *participants;

@end

@implementation SBCreateReelViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [SBTextFieldTableViewCell registerNibToTableView:self.tableView];

    [self setParticipants:[NSSet new]];
    
    AVPlayer *player = [[AVPlayer alloc] initWithURL:self.initialRecordingURL];
    [self.playerView setPlayer:player];
    [(AVPlayerLayer *)self.playerView.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [self.finishButton setImageTintColor:[UIColor whiteColor]];
    [self.createNewGroupLabel setFont:[UIFont fontWithName:[UIFont snowballFontNameMedium] size:self.createNewGroupLabel.font.pointSize]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisppear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - View Actions

- (IBAction)finish:(id)sender {
    SBTextFieldTableViewCell *cell = (SBTextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SBCreateReelTableViewSectionName]];
    NSString *reelName = cell.textField.text;
    // This is semi duplicated code since clips are uploaded in two places.
    SBReel *reel = [SBReel MR_createEntity];
    SBClip *clip = [SBClip MR_createEntity];
    [clip setReel:reel];
    [clip setVideoURL:[self.initialRecordingURL absoluteString]];
    [clip setUser:[SBUser currentUser]];
    [clip setCreatedAt:[NSDate date]];
    [reel setName:reelName];
    [reel setParticipants:self.participants];
    [reel save];
    [clip save];
    [SBLongRunningTaskManager addBlockToQueue:^{
        [clip create];
    }];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)findFriends:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"People" bundle:nil];
    SBFindFriendsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:[SBFindFriendsViewController identifier]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SBCreateReelTableViewSectionName:
            return 1;
            break;
        case SBCreateReelTableViewSectionParticipants: {
            id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[[self controller:self.fetchedResultsController originalSectionIndexFromMappedSectionIndex:section]];
            return [sectionInfo numberOfObjects];
        }
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SBCreateReelTableViewSectionName: {
            SBTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SBTextFieldTableViewCell identifier] forIndexPath:indexPath];
            [self configureCell:cell atIndexPath:indexPath];
            return cell;
        }
            break;
        case SBCreateReelTableViewSectionParticipants: {
            return [super tableView:tableView cellForRowAtIndexPath:indexPath];
        }
    }
    return nil;
}

- (void)configureCell:(SBTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell.textLabel setFont:[UIFont fontWithName:[UIFont snowballFontNameBook] size:20]];
    [cell setTintColor:[UIColor snowballColorBlue]];

    switch (indexPath.section) {
        case SBCreateReelTableViewSectionName: {
            SBTextFieldTableViewCell *_cell = (SBTextFieldTableViewCell *)cell;
            [_cell.textField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Add subject..." attributes:@{NSForegroundColorAttributeName: [UIColor snowballColorBlue]}]];
            [_cell.textField setTextColor:[UIColor snowballColorBlue]];
        }
            break;
        case SBCreateReelTableViewSectionParticipants: {
            SBUserTableViewCell *_cell = (SBUserTableViewCell *)cell;
            NSIndexPath *offsetIndexPath = [self controller:self.fetchedResultsController originalIndexPathFromMappedIndexPath:indexPath];
            SBUser *user = [self.fetchedResultsController objectAtIndexPath:offsetIndexPath];
            [_cell configureForObject:user delegate:self];
            [_cell setStyle:SBUserTableViewCellStyleSelectable];
            [_cell setChecked:NO];
            [_cell setTintColor:[UIColor snowballColorBlue]];
        }
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SBCreateReelTableViewSectionName:
            return @"Subject";
            break;
        case SBCreateReelTableViewSectionParticipants:
            return @"Participants";
            break;
    }
    return nil;
}

#pragma mark - NSFetchedResultsController Custom Mapping

- (NSUInteger)controller:(NSFetchedResultsController *)controller mappedSectionIndexFromOriginalSectionIndex:(NSUInteger)originalSectionIndex {
    return SBCreateReelTableViewSectionParticipants;
}

- (NSUInteger)controller:(NSFetchedResultsController *)controller originalSectionIndexFromMappedSectionIndex:(NSUInteger)mappedSectionIndex {
    return 0;
}

- (NSIndexPath *)controller:(NSFetchedResultsController *)controller mappedIndexPathFromOriginalIndexPath:(NSIndexPath *)originalIndexPath {
    return [NSIndexPath indexPathForRow:originalIndexPath.row inSection:SBCreateReelTableViewSectionParticipants];
}

- (NSIndexPath *)controller:(NSFetchedResultsController *)controller originalIndexPathFromMappedIndexPath:(NSIndexPath *)mappedIndexPath {
    return [NSIndexPath indexPathForRow:mappedIndexPath.row inSection:0];
}

#pragma mark - SBUserTableViewCellDelegate

- (void)userCellSelected:(SBUserTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSIndexPath *offsetIndexPath = [self controller:self.fetchedResultsController originalIndexPathFromMappedIndexPath:indexPath];
    SBUser *user = [self.fetchedResultsController objectAtIndexPath:offsetIndexPath];
    BOOL participating = [self.participants containsObject:user];
    [cell setChecked:!participating];
    NSMutableSet *mutableParticipants = [self.participants mutableCopy];
    if (participating) {
        [mutableParticipants removeObject:user];
    } else {
        [mutableParticipants addObject:user];
    }
    [self setParticipants:[mutableParticipants copy]];
}

@end
