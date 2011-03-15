//
//  FavouritesTableViewController.m
//  Slake
//
//  Created by Ben Williamson on 7/04/10.
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

#import "FavouritesTableViewController.h"
#import "Favourites.h"
#import "Place.h"
#import "PlaceCell.h"
#import "DataManager.h"
#import "PlaceDetailViewController.h"


@interface FavouritesTableViewController () // private methods

- (void)itemCountChanged;

@end



@implementation FavouritesTableViewController

@synthesize favouritesHelpView;


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[favouritesHelpView release];
    [super dealloc];
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	self.favouritesHelpView = nil;
	[super viewDidUnload];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = @"Favourites";

	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

	[[NSBundle mainBundle] loadNibNamed:@"FavouritesHelp" owner:self options:nil];
}

//notification is passed when this method is called from an event
- (void)loadDataIfNeeded:(NSNotification*)notification
{
	Favourites* favourites = [Favourites favourites];
	for (int i = 0; i < [favourites count]; i++) {
		[[DataManager manager] loadPlace:[favourites itemAtIndex:i] entire:NO force:NO];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[[DataManager manager] clearQueue];
	[self loadDataIfNeeded:nil];
    [super viewWillAppear:animated];
	[self.tableView reloadData];

	if (![favouritesHelpView isDescendantOfView:self.view.superview]) {
		[self.view.superview addSubview:favouritesHelpView];
	}
	[self itemCountChanged];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loadDataIfNeeded:)
												 name:UIApplicationDidBecomeActiveNotification
											   object:nil];
}

/*
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}
*/

- (void)viewDidDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
	[super viewDidDisappear:animated];
	self.editing = NO;
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

// Shake to reload:

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self becomeFirstResponder];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	if (motion == UIEventSubtypeMotionShake) {
		[[DataManager manager] explicitLoadRequested];
		[[DataManager manager] clearQueue];
		Favourites* favourites = [Favourites favourites];
		for (int i = 0; i < [favourites count]; i++) {
			[[DataManager manager] loadPlace:[favourites itemAtIndex:i] entire:NO force:YES];
		}
	}
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[Favourites favourites] count];
}

- (void)configurePlaceCell:(PlaceCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	cell.place = [[Favourites favourites] itemAtIndex:indexPath.row];
	
	// Now adjust the subview positions (they are optimised for the group table view, not the plain style that we use here)
	cell.nameLabel.frame      = CGRectMake(8.0f, 1.0f, 235.0f, 31.0f);
	cell.capacityTitle.frame  = CGRectMake(10.0f, 30.0f, 235.0f, 31.0f);
	cell.capacityLabel.frame  = CGRectMake(68.0f, 26.0f, 245.0f, 18.0f);
	cell.percentLabel.frame    = CGRectMake(224.0f, 2.0f, 80.0f, 31.0f);
	cell.volumeLabel.frame    = CGRectMake(184.0f, 25.0f, 120.0f, 18.0f);
	
	CGRect levelBarFrame = cell.levelBar.frame;
	levelBarFrame.origin.x  = 0.0f;
	cell.levelBar.frame = levelBarFrame;
	
	CGRect selectedLevelBarFrame = cell.selectedLevelBar.frame;
	selectedLevelBarFrame.origin.x  = 0.0f;
	cell.selectedLevelBar.frame = selectedLevelBarFrame;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Place* place = [[Favourites favourites] itemAtIndex:indexPath.row];
	PlaceDetailViewController* detail = [[[PlaceDetailViewController alloc] initWithPlace:place] autorelease];
	[self.navigationController pushViewController:detail animated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		[[Favourites favourites] removeItemAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
	[self itemCountChanged];
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	[[Favourites favourites] moveItemAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (void)itemCountChanged
{
	if ([[Favourites favourites] count] != 0) {
		[favouritesHelpView setHidden:YES];
	} else {
		[favouritesHelpView setHidden:NO];
	}
}

@end

