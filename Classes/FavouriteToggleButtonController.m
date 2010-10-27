//
//  FavouriteToggleButtonController.m
//  Slake
//
//  Created by Ben Williamson on 20/04/10.
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

#import "FavouriteToggleButtonController.h"
#import "Favourites.h"
#import "Place.h"


@interface FavouriteToggleButtonController ()	// private

@property (nonatomic, retain) UIImage* imageOn;
@property (nonatomic, retain) UIImage* imageOff;

- (void)setImage;

@end


@implementation FavouriteToggleButtonController


@synthesize item;
@synthesize imageOn;
@synthesize imageOff;
@synthesize place;


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[item release];
	[imageOn release];
	[imageOff release];
	[place release];
    [super dealloc];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	self.imageOn = [UIImage imageNamed:@"favstar_on.png"];
	self.imageOff = [UIImage imageNamed:@"favstar_off.png"];
	item.accessibilityLabel = @"Favourite star";
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setImage) name:nil object:[Favourites favourites]];
}

- (void)setItem:(UIBarButtonItem *)newItem
{
	if (item != newItem) {
		[item release];
		item = [newItem retain];
		[self setImage];
	}
}

- (void)setPlace:(Place *)newPlace
{
	if (place != newPlace) {
		[place release];
		place = [newPlace retain];
		[self setImage];
	}
}

- (void)toggle:(id)sender
{
	if ([[Favourites favourites] containsItem:place]) {
		[[Favourites favourites] removeItem:place];
	} else {
		[[Favourites favourites] addItem:place];
	}
	[self setImage];
}

- (void)setImage
{
	if ([[Favourites favourites] containsItem:place])
	{
		item.image = imageOn;
		item.accessibilityValue = @"on";
	}
	else
	{
		item.image = imageOff;
		item.accessibilityValue = @"off";
	}
}

@end
