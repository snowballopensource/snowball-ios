//
//  SBManagedTableViewController.m
//  Snowball
//
//  Created by James Martinez on 5/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBManagedTableViewController.h"

@interface SBManagedTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSUInteger currentPage;

@end

@implementation SBManagedTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // When the view loads, the infinite scroll will automatically
    // start pulling more objects. We set loading to YES to prevent
    // further loading until original data is received.
    [self setIsLoading:YES];
    
    // By default, enable pull to refresh and infinite scroll.
    [self setPullToRefreshEnabled:YES];
    [self setInfiniteScrollEnabled:YES];
    
    [self setupPullToRefresh];
    
    // Start loading remote objects on first page immediately.
    [self setCurrentPage:1];
    [self getRemoteObjects];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

#pragma mark - Pull to Refresh

- (void)setupPullToRefresh {
    if (self.pullToRefreshEnabled) {
        // Since UIRefreshControls are not allowed without a UITableViewController, we do
        // this hack. See details here:
        // http://stackoverflow.com/questions/12497940/uirefreshcontrol-without-uitableviewcontroller
        UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:self.tableView.style];
        [tableViewController setTableView:self.tableView];
        [self setRefreshControl:[UIRefreshControl new]];
        [self.refreshControl bk_addEventHandler:^(id sender) {
            [self setIsLoading:YES];
            [self setCurrentPage:1];
            [self getRemoteObjects];
        } forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:self.refreshControl];
        [tableViewController setRefreshControl:self.refreshControl];
    }
}

#pragma mark - Working with Cells

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    REQUIRE_SUBCLASS
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    REQUIRE_SUBCLASS
    return nil;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.infiniteScrollEnabled) {
        if (scrollView.contentSize.height - scrollView.contentOffset.y < self.view.bounds.size.height) {
            unless(self.isLoading) {
                [self setIsLoading:YES];
                [self setCurrentPage:self.currentPage+1];
                [self getRemoteObjects];
            }
        }
    }
}

#pragma mark - Actions

- (void)getRemoteObjects {
    REQUIRE_SUBCLASS
}

@end
