//
//  FetchedPlaceTableViewController.m
//  Slake
//
//  Created by Ben Williamson on 14/05/10.
//
//  Copyright (c) 2010 Bureau of Meteorology
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "FetchedPlaceTableViewController.h"
#import "PlaceDetailViewController.h"
#import "PlaceCell.h"


@class Place;


@implementation FetchedPlaceTableViewController


@synthesize fetchedResultsController;


- (void)dealloc
{
	[fetchedResultsController release];
	[super dealloc];
}

- (void)viewDidUnload
{
	self.fetchedResultsController = nil;
	[super viewDidUnload];
}

- (NSFetchedResultsController*)fetchedResultsController
{
	if (fetchedResultsController == nil) {
		self.fetchedResultsController = [self makeFetchedResultsController];
		fetchedResultsController.delegate = self;
	}
	return fetchedResultsController;
}

- (NSFetchedResultsController*)makeFetchedResultsController
{
	return nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// FIXME Handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
    [super viewWillAppear:animated];
}


#pragma mark Table view methods

// Number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	NSInteger count = [[self.fetchedResultsController sections] count];
	return count;
}

// Number of rows in section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
	
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    return numberOfRows;
}

// Section title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo name];
}

// Cell contents
- (void)configurePlaceCell:(PlaceCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	Place* place = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.place = place;
}

// Select row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Place* place = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	PlaceDetailViewController* detail = [[[PlaceDetailViewController alloc] initWithPlace:place] autorelease];
	[self.navigationController pushViewController:detail animated:YES];
}


#pragma mark -
#pragma mark Fetched results controller delegate

// Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView reloadData];
}

@end

