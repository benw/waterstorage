//
//  PlaceCell.m
//  Slake
//
//  Created by Ben Williamson on 16/04/10.
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

#import "PlaceCell.h"
#import "Place.h"
#import "PlaceType.h"
#import "Observation.h"
#import "Measurement.h"


@interface PlaceCell ()	// private

- (void)updatePlaceDetails;

@end


@implementation PlaceCell


@synthesize nameLabel;
@synthesize capacityLabel;
@synthesize capacityTitle;
@synthesize percentLabel;
@synthesize volumeLabel;
@synthesize typeLabel;
@synthesize levelBar;
@synthesize selectedLevelBar;
@synthesize place;


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[place release];
	[nameLabel release];
	[capacityLabel release];
	[capacityTitle release];
	[percentLabel release];
	[volumeLabel release];
	[typeLabel release];
	[levelBar release];
	[selectedLevelBar release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

- (void)setPlace:(Place *)newPlace
{
	if (newPlace != place) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:[place managedObjectContext]];
		[place release];
		place = [newPlace retain];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectsDidChangeNotification:) name:NSManagedObjectContextObjectsDidChangeNotification object:[place managedObjectContext]];
		[self updatePlaceDetails];
	}
}

- (void)objectsDidChangeNotification:(NSNotification*)notification
{
	NSSet* updated = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
	NSSet* refreshed = [[notification userInfo] objectForKey:NSRefreshedObjectsKey];
	if ([refreshed containsObject:place] || [updated containsObject:place]) {
		[self updatePlaceDetails];
	}
}

- (void)updatePlaceDetails
{
	Measurement* measurement = place.obsCurrent.percentageVolume;
	
	UIColor *bomBrightBlueColour = [[[UIColor alloc] initWithRed:0.0/255.0 green:121.0/255.0 blue:205.0/255.0 alpha:1.0] autorelease];
	UIColor *bomCharcoalColour = [[[UIColor alloc] initWithRed:16.0/255.0 green:29.0/255.0 blue:36.0/255.0 alpha:1.0] autorelease];
	
	CGRect bar = self.levelBar.frame;
	bar.size = CGSizeMake(320.0f * 0.01f * measurement.value, bar.size.height);
	self.levelBar.frame = bar;
	bar = self.selectedLevelBar.frame;
	bar.size = CGSizeMake(320.0f * 0.01f * measurement.value, bar.size.height);
	self.selectedLevelBar.frame = bar;
	
	self.nameLabel.text = place.longName;
	self.typeLabel.text = place.type.singular;
	[self.percentLabel setMeasurementAsPercentage:measurement forceSign:NO];
	self.percentLabel.textColor = measurement ? bomCharcoalColour : [UIColor grayColor];
	[self.capacityLabel setMeasurementAsVolume:place.obsCurrent.capacity forceSign:NO];
	self.capacityLabel.textColor = place.obsCurrent.capacity ? bomBrightBlueColour : [UIColor grayColor];
	[self.volumeLabel setMeasurementAsVolume:place.obsCurrent.volume forceSign:NO];
	self.volumeLabel.textColor = place.obsCurrent.volume ? bomBrightBlueColour : [UIColor grayColor];
}

@end
