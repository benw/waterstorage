//
//  SearchViewController.m
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

#import "SearchViewController.h"
#import "Place.h"
#import "PlaceType.h"
#import "PlaceCell.h"
#import "DataManager.h"

@interface SearchViewController ()	// private

@property (nonatomic, retain) UISearchBar* searchBar;
@property (nonatomic, retain) UISearchDisplayController* searchController;

@end

@implementation SearchViewController

@synthesize searchBar;
@synthesize searchController;


- (void)dealloc
{
	[searchBar release];
	[searchController release];
	[super dealloc];
}

- (void)viewDidUnload
{
	self.searchBar = nil;
	self.searchController = nil;
	[super viewDidUnload];
}

- (NSString*)placeCellNibName
{
	return @"SearchPlaceCell";
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
	searchBar.delegate = self;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.tintColor = [UIColor colorWithRed:0.0/255.0 green:90.0/255.0 blue:170.0/255.0 alpha:1.0];
	self.tableView.tableHeaderView = searchBar;
	
	self.searchController = [[[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self] autorelease];
	searchController.delegate = self;
	searchController.searchResultsDelegate = self;
	searchController.searchResultsDataSource = self;
}

- (void)configurePlaceCell:(PlaceCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	[super configurePlaceCell:cell atIndexPath:indexPath];
	//Adaptative name label width: will truncate text just before it overlaps on the type label
	CGRect nameFrame = cell.nameLabel.frame;
	CGSize expectedLabelSize = [cell.typeLabel.text
								sizeWithFont:cell.typeLabel.font
								constrainedToSize:cell.typeLabel.frame.size
								lineBreakMode:cell.typeLabel.lineBreakMode];
	nameFrame.size.width = CGRectGetMaxX(cell.typeLabel.frame) - nameFrame.origin.x - expectedLabelSize.width - 3;
	cell.nameLabel.frame = nameFrame;
}

#pragma mark -
#pragma mark Search bar delegate

- (void)searchBar:(UISearchBar *)sb textDidChange:(NSString *)searchText
{
	self.fetchedResultsController = nil;
	[self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)sb
{
	searchBar.text = @"";
	self.fetchedResultsController = nil;
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark UISearchDisplay delegate

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
	tableView.rowHeight       = self.tableView.rowHeight;
	tableView.separatorStyle  = self.tableView.separatorStyle;
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController*)makeFetchedResultsController
{
	NSManagedObjectContext* managedObjectContext = [[DataManager manager] rootContext];
	
	// Create the fetch request
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:[Place entity]];
	
	NSString* searchString = searchBar.text;
	
	if (searchString == nil || [searchString isEqualToString:@""]) {
		// No predicate required, match everything
	} else {
		// shortName BEGINSWITH searchString -- e.g. "nsw" matches New South Wales
		// longName BEGINSWITH searchString  -- e.g. "new" matches New South Wales
		// longName CONTAINS " searchString" -- e.g. "jin" matches Lake Jindabyne
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(shortName BEGINSWITH[cd] %@ || longName BEGINSWITH[cd] %@ || longName CONTAINS[cd] %@)",
								  searchString, searchString, [NSString stringWithFormat:@" %@", searchString]];
		[fetchRequest setPredicate:predicate];
	}
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"longName" ascending:YES] autorelease];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSFetchedResultsController* frc = [[[NSFetchedResultsController alloc]
				 initWithFetchRequest:fetchRequest
				 managedObjectContext:managedObjectContext
				 sectionNameKeyPath:nil
				 cacheName:nil] autorelease];

	NSError *error = nil;
	if (![frc performFetch:&error]) {
		// FIXME Handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
	return frc;
}

@end

