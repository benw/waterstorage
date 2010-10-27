//
//  PlaceTableViewController.h
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

#import <UIKit/UIKit.h>


@class PlaceCell;


// A table where the cells are PlaceCells.
// Handles loading of cells from a nib.

@interface PlaceTableViewController : UITableViewController
{
	PlaceCell* placeCell;
}

@property (nonatomic, retain) IBOutlet PlaceCell* placeCell;

// Returns @"PlaceCell" by default.
// Optionally override in subclass to load a different nib.
- (NSString*)placeCellNibName;

// Called by tableView:cellForRowAtIndexPath: after dequeueing or loading a PlaceCell.
// The default implementation calls configurePlaceCell:atIndexPath:.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

// Called (indirectly) by tableView:cellForRowAtIndexPath: after dequeueing or loading a PlaceCell.
// Subclass must override and set cell.place at minimum. Default implementation does nothing.
- (void)configurePlaceCell:(PlaceCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
