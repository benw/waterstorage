//
//  SlakeAppDelegate.m
//  Slake
//
//  Created by Ben Williamson on 11/02/10.
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

#import "SlakeAppDelegate.h"
#import "PlaceDetailViewController.h"
#import "DataManager.h"
#import "Place.h"
#import "PlaceType.h"
#import "Observation.h"
#import "FavouritesTableViewController.h"
#import "Favourites.h"
#import "AboutViewController.h"
#import "SearchViewController.h"


@interface SlakeAppDelegate ()	// private

enum TabTag;

- (id)navigationControllerForTabTag:(enum TabTag)tag;

@end


@implementation SlakeAppDelegate

@synthesize window;
@synthesize tabBarController;


#pragma mark -
#pragma mark Application lifecycle

enum TabTag {
	kTabTagFavourites,
	kTabTagPlaces,
	kTabTagNearby,
	kTabTagSearch,
	kTabTagAbout
};

static const enum TabTag defaultTabOrder[] = {
	kTabTagFavourites,
	kTabTagPlaces,
	//kTabTagNearby,
	kTabTagSearch,
	kTabTagAbout
};

static int kDefaultTabTag = kTabTagPlaces;

static const int kNumTabs = sizeof(defaultTabOrder) / sizeof(defaultTabOrder[0]);

static NSString* kTabOrderKey = @"tabOrder";
static NSString* kSelectedTabTagKey = @"selectedTabTag";

static float kSplashSeconds = 1.0f;


- (id)navigationControllerForTabTag:(enum TabTag)tag
{
	UINavigationController* nav = [[[UINavigationController alloc] init] autorelease];
  [nav navigationBar].tintColor = [UIColor colorWithRed:0.0/255.0 green:110.0/255.0 blue:172.0/255.0 alpha:1.0];

	switch (tag) {
		case kTabTagFavourites: {
			nav.tabBarItem = [[[UITabBarItem alloc]
							   initWithTitle:@"Favourites"
							   image:[UIImage imageNamed:@"tab-star.png"]
							   tag:tag] autorelease];

			FavouritesTableViewController* table;
			table = [[[FavouritesTableViewController alloc] init] autorelease];
			[nav pushViewController:table animated:NO];
			break;
		}
		case kTabTagPlaces: {
			nav.tabBarItem = [[[UITabBarItem alloc]
							  initWithTitle:@"Places"
							  image:[UIImage imageNamed:@"tab-australia.png"]
							  tag:tag] autorelease];
			
			NSManagedObjectContext* context = [[DataManager manager] rootContext];
			PlaceDetailViewController* details = [[[PlaceDetailViewController alloc] initWithPlace:[Place australiaInContext:context]] autorelease];
			[nav pushViewController:details animated:NO];
			break;
		}
		case kTabTagNearby: {
			nav.tabBarItem = [[[UITabBarItem alloc]
							  initWithTitle:@"Nearby"
							  image:[UIImage imageNamed:@"tab-nearby.png"]
							  tag:tag] autorelease];
			
			UITableViewController* table = [[[UITableViewController alloc] init] autorelease];	// FIXME
			table.title = @"Nearby";
			[nav pushViewController:table animated:NO];
			break;
		}
		case kTabTagSearch: {
			nav.tabBarItem = [[[UITabBarItem alloc]
							   initWithTitle:@"Search"
							   image:[UIImage imageNamed:@"tab-search.png"]
							   tag:tag] autorelease];
			
			SearchViewController* table = [[[SearchViewController alloc] init] autorelease];
			table.title = @"Search";
			[nav pushViewController:table animated:NO];
			break;
		}
		case kTabTagAbout: {
			nav.tabBarItem = [[[UITabBarItem alloc]
							  initWithTitle:@"About"
							  image:[UIImage imageNamed:@"tab-about.png"]
							  tag:tag] autorelease];
			
			AboutViewController* about = [[[AboutViewController alloc] init] autorelease];
			about.title = @"About";
			[nav pushViewController:about animated:NO];
			break;
		}
	}
	return nav;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	NSDate* launchDate = [NSDate date];
	
	NSManagedObjectContext* context = [[DataManager manager] rootContext];
	[PlaceType loadPlaceTypesInContext:context];
	[Place australiaInContext:context].type = [PlaceType countryInContext:context];
	[[DataManager manager] loadAllNewPlaces];
	
	enum TabTag tabOrder[kNumTabs];
	
	NSArray* savedTabOrder = nil; // [[NSUserDefaults standardUserDefaults] arrayForKey:kTabOrderKey];
	if (savedTabOrder && [savedTabOrder count] == kNumTabs) {
		for (int i = 0; i < kNumTabs; i++) {
			tabOrder[i] = [[savedTabOrder objectAtIndex:i] intValue];
		}
	} else {
		for (int i = 0; i < kNumTabs; i++) {
			tabOrder[i] = defaultTabOrder[i];
		}
	}

	NSMutableArray* tabs = [[NSMutableArray alloc] init];
	for (int i = 0; i < kNumTabs; i++) {
		enum TabTag tag = tabOrder[i];
		id tabNavController = [self navigationControllerForTabTag:tag];
		[tabs addObject:tabNavController];
	}

	self.tabBarController = [[[UITabBarController alloc] init] autorelease];
	tabBarController.viewControllers = tabs;
	[tabs release];
	
	NSNumber* savedTabTag = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedTabTagKey];
	enum TabTag selectedTabTag = savedTabTag ? [savedTabTag intValue] : kDefaultTabTag;
	for (int i = 0; i < kNumTabs; i++) {
		if (selectedTabTag == tabOrder[i]) {
			tabBarController.selectedIndex = i;
			break;
		}
	}
	
	[window addSubview:[tabBarController view]];
    [window makeKeyAndVisible];
	
	NSDate* endSplashDate = [launchDate addTimeInterval:kSplashSeconds];
	[NSThread sleepUntilDate:endSplashDate];
}


- (void)saveTabOrder
{
	enum TabTag selectedTabTag = tabBarController.selectedViewController.tabBarItem.tag;
	[[NSUserDefaults standardUserDefaults] setInteger:selectedTabTag forKey:kSelectedTabTagKey];
	
	NSMutableArray* tabOrder = [[[NSMutableArray alloc] init] autorelease];
	NSArray* tabs = tabBarController.viewControllers;
	for (int i = 0; i < [tabs count]; i++) {
		enum TabTag tag = [[[tabs objectAtIndex:i] tabBarItem] tag];
		[tabOrder addObject:[NSNumber numberWithInt:tag]];
	}
	[[NSUserDefaults standardUserDefaults] setObject:tabOrder forKey:kTabOrderKey];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[self saveTabOrder];
	[[DataManager manager] suspendLoading];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[self saveTabOrder];
	[[DataManager manager] suspendLoading];
	NSLog(@"Suspended");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	NSLog(@"Resuming");
	[[DataManager manager] resumeLoading];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
	[tabBarController release];
	[window release];
	[super dealloc];
}

@end

