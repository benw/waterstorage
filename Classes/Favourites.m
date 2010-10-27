//
//  Favourites.m
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

#import "Favourites.h"
#import "Place.h"
#import "DataManager.h"


@interface Favourites ()	// private

@property (nonatomic, retain) NSArray* items;

@end


@implementation Favourites


static NSString* kFavouritesKey = @"favouritesData";

@synthesize items;


+ (Favourites*)favourites
{
	static Favourites* favourites = nil;
	
	if (nil == favourites) {
		NSData* data = [[NSUserDefaults standardUserDefaults] dataForKey:kFavouritesKey];
		if (data) {
			favourites = [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
		} else {
			favourites = [[Favourites alloc] init];
		}
	}
	return favourites;
}

- (void)dealloc
{
	[items release];
	[super dealloc];
}

- (id)init
{
	if ((self = [super init])) {
		self.items = [[[NSMutableArray alloc] init] autorelease];
	}
	return self;
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if ((self = [super init])) {
		self.items = [[[NSMutableArray alloc] init] autorelease];
		NSArray* itemUrns = [decoder decodeObjectForKey:@"itemUrns"];
		NSManagedObjectContext* context = [[DataManager manager] rootContext];
		for (NSString* urn in itemUrns) {
			Place* place = [Place placeWithUrn:urn context:context];
			[items addObject:place];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
	NSMutableArray* itemUrns = [NSMutableArray array];
	for (Place* place in items) {
		[itemUrns addObject:place.urn];
	}
	[encoder encodeObject:itemUrns forKey:@"itemUrns"];
}

- (void)save
{
	NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self];
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:kFavouritesKey];
}



- (NSUInteger)count
{
	return [items count];
}

- (id)itemAtIndex:(NSUInteger)index
{
	return [items objectAtIndex:index];
}

- (void)addItem:(id)item
{
	[items addObject:item];
	[self save];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FavouritesChanged" object:self];
}

- (void)removeItem:(id)item
{
	[items removeObject:item];
	[self save];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FavouritesChanged" object:self];
}

- (void)removeItemAtIndex:(NSUInteger)index
{
	[items removeObjectAtIndex:index];
	[self save];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FavouritesChanged" object:self];
}

- (BOOL)containsItem:(id)item
{
	return [items containsObject:item];
}

- (void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
	id item = [items objectAtIndex:fromIndex];
	[item retain];
	[items removeObjectAtIndex:fromIndex];
	[items insertObject:item atIndex:toIndex];
	[item release];
	[self save];
}

@end
