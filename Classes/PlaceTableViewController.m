//
//  PlaceTableViewController.m
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

#import "PlaceTableViewController.h"
#import "PlaceCell.h"


@implementation PlaceTableViewController

@synthesize placeCell;


- (void)dealloc
{
	[placeCell release];
	[super dealloc];
}

- (void)viewDidUnload
{
	self.placeCell = nil;
	[super viewDidUnload];
}

- (NSString*)placeCellNibName
{
	return @"PlaceCell";
}

- (NSString*)placeCellReuseIdentifier
{
	// This should be set as the cell Identifer in PlaceCell.xib, SearchPlaceCell.xib etc.
	return @"PlaceCell";
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.tableView.backgroundColor = [UIColor whiteColor];
	self.tableView.clearsContextBeforeDrawing = YES;
	self.tableView.opaque = YES;
	
	// Briefly load a cell in order to grab the row height,
	// then throw it away.
	[[NSBundle mainBundle] loadNibNamed:[self placeCellNibName] owner:self options:nil];
	self.tableView.rowHeight = self.placeCell.frame.size.height;
	self.placeCell = nil;
}


#pragma mark Table view methods

// Cell contents
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{  
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.placeCellReuseIdentifier];
	if (cell == nil) {
		if (!self.placeCell) {
			[[NSBundle mainBundle] loadNibNamed:[self placeCellNibName] owner:self options:nil];
		}
		// While the following looks like a memory leak, it is apparently the right thing
		// to do according to Apple's sample code, e.g. AdvancedTableViewCells:
		cell = self.placeCell;
		self.placeCell = nil;
	}
	
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	[self configurePlaceCell:(PlaceCell *)cell atIndexPath:indexPath];
}

- (void)configurePlaceCell:(PlaceCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

@end

