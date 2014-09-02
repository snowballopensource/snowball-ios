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
    [self.refreshControl beginRefreshing];
    [self.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];

    [super viewDidDisappear:animated];
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
    NSUInteger mappedSectionIndex = [self controller:controller mappedSectionIndexFromOriginalSectionIndex:sectionIndex];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:mappedSectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:mappedSectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    NSIndexPath *mappedIndexPath = [self controller:controller mappedIndexPathFromOriginalIndexPath:indexPath];
    NSIndexPath *mappedNewIndexPath = [self controller:controller mappedIndexPathFromOriginalIndexPath:newIndexPath];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[mappedNewIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[mappedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:mappedIndexPath] atIndexPath:mappedIndexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[mappedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[mappedNewIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - NSFetchedResultsController Custom Mapping

- (NSUInteger)controller:(NSFetchedResultsController *)controller mappedSectionIndexFromOriginalSectionIndex:(NSUInteger)originalSectionIndex {
    return originalSectionIndex;
}

- (NSUInteger)controller:(NSFetchedResultsController *)controller originalSectionIndexFromMappedSectionIndex:(NSUInteger)mappedSectionIndex {
    return mappedSectionIndex;
}

- (NSIndexPath *)controller:(NSFetchedResultsController *)controller mappedIndexPathFromOriginalIndexPath:(NSIndexPath *)originalIndexPath {
    return originalIndexPath;
}

- (NSIndexPath *)controller:(NSFetchedResultsController *)controller originalIndexPathFromMappedIndexPath:(NSIndexPath *)mappedIndexPath {
    return mappedIndexPath;
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
