//
//  DataManager.m
//  Slake
//
//  Created by Ben Williamson on 30/04/10.
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

#import "DataManager.h"
#import "Place.h"
#import "Chart.h"
#import "PlaceParser.h"
#import "PlaceRequest.h"
#import "ChartRequest.h"
#import "Reachability.h"
#import "DataLoader.h"

#ifdef CHARTS_INTEGRATION_TEST
#import "ChartParser.h"
#import "NSManagedObjectContext+Helpers.h"
#endif

// Production: water.bom.gov.au
// Test:       cdcvt-awwaapp02.bom.gov.au:8080
NSString* const kHostName = @"water.bom.gov.au";
NSString* const kBaseURL = @"http://water.bom.gov.au/waterstorage/";

// flag for model fix stored in store to address corrupted data problem
NSString* const kCustomMetadataModelFixedChartDeleteRule = @"ChartDeletionRuleInModelFixed";

@interface DataManager ()	// private

@property (nonatomic, retain) id <DataRequestProtocol> requestInProgress;
@property (nonatomic, retain) DataLoader* loaderInProgress;
@property (nonatomic, retain) NSMutableArray* queue;
@property (nonatomic, retain) Reachability* reachability;

- (void)checkQueue;
- (void)startLoadingRequest:(id <DataRequestProtocol>)request;
- (void)enqueueRequest:(id <DataRequestProtocol>)request;
- (void)showNetworkAlert;
- (NSString*)storePath;
- (NSURL*)storeURL;
- (void)installDefaultStore;

- (NSString *)applicationDocumentsDirectory;

@end


@implementation DataManager

@synthesize requestInProgress;
@synthesize loaderInProgress;
@synthesize queue;
@synthesize reachability;


+ (DataManager*)manager
{
	static DataManager* manager = nil;
	
	if (manager == nil) {
		manager = [[DataManager alloc] init];
	}
	return manager;
}

+ (NSString*)baseUrl
{
	return kBaseURL;
}

static const NSTimeInterval expireSeconds = 6 * 60 * 60;	// 6hr

+ (BOOL)dateIsRecentEnough:(NSDate*)date
{
	if (!date) {
		return NO;
	}
	NSDate* now = [NSDate date];
	NSTimeInterval seconds = [now timeIntervalSinceDate:date];
	return seconds < expireSeconds;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[requestInProgress release];
	[loaderInProgress release];
	[reachability release];
	[queue release];
	[super dealloc];
}

- (id)init
{
	if ((self = [super init])) {
		self.queue = [[[NSMutableArray alloc] init] autorelease];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyNewPlace:) name:kNewPlaceNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
		self.reachability = [Reachability reachabilityWithHostName:kHostName];
		[self.reachability startNotifer];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextSaved:) name:NSManagedObjectContextDidSaveNotification object:nil];
	}
	return self;
}

- (void)notifyNewPlace:(NSNotification*)notification
{
	// This notification may be invoked on any thread.
	NSString* urn = [notification object];
	[self performSelectorOnMainThread:@selector(loadNewPlaceWithURN:) withObject:urn waitUntilDone:NO];
}

- (void)loadNewPlaceWithURN:(NSString*)urn
{
	assert([NSThread isMainThread]);
	Place* place = [Place placeWithUrn:urn context:self.rootContext];
	[self loadPlace:place entire:YES force:NO];
}

- (void)reachabilityChanged:(NSNotification*)notification
{
	assert([NSThread isMainThread]);
	[self checkQueue];
}

- (void)managedObjectContextSaved:(NSNotification*)notification
{
//	NSLog(@"Context saved: %@", [notification object]);
//	NSLog(@"Changes: %@", notification);
	// This notification may be invoked on any thread.
	[self performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:NO];
}

- (void)mergeChangesFromContextDidSaveNotification:(NSNotification*)notification
{
	if ([notification object] != self.rootContext) {
		[self.rootContext mergeChangesFromContextDidSaveNotification:notification];
	}
}

- (void)loadAllNewPlaces
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[Place entity]];
	
	NSError* error;
	NSArray* array = [self.rootContext executeFetchRequest:fetchRequest error:&error];
	
	for (Place* place in array) {
		if (place.loadDate == nil) {
			NSLog(@"%@ has never been loaded (%@)", place.longName, place.urn);
			[self loadPlace:place entire:YES force:NO];
		}
	}
	
	[fetchRequest release];
}

- (void)loadPlace:(Place*)place entire:(BOOL)entire force:(BOOL)force;
{
#ifndef CHARTS_INTEGRATION_TEST
	assert([NSThread isMainThread]);
	id <DataRequestProtocol> request = [PlaceRequest placeRequestForPlace:place entire:entire force:force];
	if (![request isSatisfied]) {
		[self enqueueRequest:request];
	}
#endif
}

- (void)loadChartForPlace:(Place*)place force:(BOOL)force
{
#ifdef GET_FRESH_PLACES
	// GET_FRESH_PLACES is used to load a clean database containing
	// only Places, no observations or charts.
	// Ignore requests to load charts.
#else
	assert([NSThread isMainThread]);
#ifdef CHARTS_INTEGRATION_TEST
	NSLog(@"loading static chart file");
	NSBundle* bundle = [NSBundle bundleForClass:[self class]];
	NSString* inputPath = [bundle pathForResource:@"integration_test_chart" ofType:@"xml"];
	NSData* data = [NSData dataWithContentsOfFile:inputPath];
	ChartParser* parser = [[[ChartParser alloc] initWithPlace:place context:self.rootContext] autorelease];
	[parser parseData:data];
	[parser parseEnd];
	[self.rootContext saveAndLogErrors];
	NSLog(@"static chart file loaded and saved in context");
#else
	id <DataRequestProtocol> request = [ChartRequest chartRequestForPlace:place force:force];
	if (![request isSatisfied]) {
		[self enqueueRequest:request];
	}
#endif
#endif
}

- (void)enqueueRequest:(id <DataRequestProtocol>)request
{
	if (![request isEqual:self.requestInProgress] && ![queue containsObject:request]) {
		[queue addObject:request];
		[self checkQueue];
	}
}

- (void)checkQueue
{
	if (![self serverIsReachable]) {
		if ([queue count] && [reachability statusIsKnown] && !networkAlertHasBeenShown) {
			[self showNetworkAlert];
		}
		return;
	}
	if (self.requestInProgress) {
		// Already busy
		return;
	}
	while (!self.requestInProgress && [queue count] > 0) {
		id <DataRequestProtocol> request = [queue objectAtIndex:0];
		if (![request isSatisfied]) {
			self.requestInProgress = request;
			NSLog(@"Loading %@", request);
			[self startLoadingRequest:request];
		}
		[queue removeObjectAtIndex:0];
	}
	if (!self.requestInProgress) {
		NSLog(@"Queue empty.");
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = self.requestInProgress != nil;
}

- (void)startLoadingRequest:(id <DataRequestProtocol>)request
{
	assert(loaderInProgress == nil);
	
	DataLoader* loader = [request makeLoader];
	loader.delegate = self;
	self.loaderInProgress = loader;
#if 1
	// Asynchronous load in a separate thread
	[loader start];
#else
	// Asynchronous load in the main thread
	[loader startLoading];
#endif
}

- (void)dataLoaderDidFinish:(DataLoader*)loader
{
	NSLog(@"Finished loading %@; request %@ satisfied",
		  self.requestInProgress,
		  [self.requestInProgress isSatisfied] ? @"is" : @"NOT");	
	self.requestInProgress = nil;
	self.loaderInProgress = nil;
	[self checkQueue];
}

- (void)clearQueue
{
	for (NSUInteger i = 0; i < [queue count]; ) {
		id <DataRequestProtocol> request = [queue objectAtIndex:i];
		if ([request isClearable]) {
			[queue removeObjectAtIndex:i];
		} else {
			i++;
		}
	}
}

- (BOOL)serverIsReachable
{
	return NotReachable != [reachability currentReachabilityStatus];
}

- (void)explicitLoadRequested
{
	if (![self serverIsReachable]) {
		[self showNetworkAlert];
	}
}

- (void)showNetworkAlert
{
	networkAlertHasBeenShown = YES;
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"No Internet Connection"
													message:@"Unable to load fresh data."
												   delegate:nil
										  cancelButtonTitle:@"OK"
										   otherButtonTitles: nil] autorelease];
	[alert show];
}

- (void)suspendLoading
{
	if (self.requestInProgress) {
		NSLog(@"Suspending load of %@", self.requestInProgress);
		[self.loaderInProgress terminateLoading];
		self.loaderInProgress = nil;
		[queue insertObject:self.requestInProgress atIndex:0];
		self.requestInProgress = nil;
	}
}

- (void)resumeLoading
{
	[self checkQueue];
}


#pragma mark -
#pragma mark Core Data stack

- (NSManagedObjectContext *)rootContext
{
    if (rootContext != nil) {
        return rootContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        rootContext = [[NSManagedObjectContext alloc] init];
        [rootContext setPersistentStoreCoordinator: coordinator];
    }
	
    return rootContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the
 models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

- (NSString*)storePath
{
	return [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Places.sqlite"];
}

- (NSURL*)storeURL
{
	return [NSURL fileURLWithPath:[self storePath]];
}

- (void)installDefaultStore
{
	NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"Places" ofType:@"sqlite"];
	if (defaultStorePath) {
		NSLog(@"Copying default store into place.");
		NSFileManager *fileManager = [NSFileManager defaultManager];
		[fileManager removeItemAtPath:[self storePath] error:nil];
		[fileManager copyItemAtPath:defaultStorePath toPath:[self storePath] error:NULL];
	} else {
		NSLog(@"Default store not found.");
	}
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
	/*
	 Set up the store.
	 Provide a pre-populated default store.
	 */
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:[self storePath]]) {
		[self installDefaultStore];
	}
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
								  initWithManagedObjectModel:[self managedObjectModel]];
	
	NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
							 nil];
	
	BOOL happy = NO;
	NSURL* storeURL = [self storeURL];
	
#ifdef GET_FRESH_PLACES
	// GET_FRESH_PLACES is used to load a clean database containing
	// only Places, no observations or charts.
	// Start with a blank store and load everything.
#else
	
	NSDictionary *metadata = [NSPersistentStoreCoordinator
							  metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeURL error:&error];
	if (metadata == nil) {
		NSLog(@"Error accessing store metadata: %@", error);
	}
	else if (![metadata objectForKey:kCustomMetadataModelFixedChartDeleteRule]) 
	{
		//possibly a corrupted store, wipe it out and install fresh one from bundle
		NSLog(@"Current store may contain places with broken reference to chart, starting with fresh store...");
		[self installDefaultStore];
	}
	
	happy = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
													 configuration:nil
															   URL:storeURL
														   options:options
															 error:&error] != nil;
	
	if (!happy) {
		// This occurs when the model changes.
		// We revert to the default store and try again.
		[self installDefaultStore];
		error = nil;
		happy = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
														 configuration:nil
																   URL:storeURL
															   options:options
																 error:&error] != nil;
	}

#endif

	if (!happy) {
		// Crap - the model differs from the default store. Should only happen in development.
		// We start with a blank store.
		[fileManager removeItemAtPath:[self storePath] error:nil];
		NSLog(@"DEBUG Removed the store.");
		
		error = nil;
		NSPersistentStore* store = 
		[persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
												 configuration:nil
														   URL:storeURL
													   options:options
														 error:&error];
		happy = store != nil;
		if (happy) {
			//Set the custom key-pair in the store, regarding model fix
			NSDictionary* metadata = [persistentStoreCoordinator metadataForPersistentStore:store];
			NSMutableDictionary* newMetadata = [[metadata mutableCopy] autorelease];
			[newMetadata setObject:@"YES" forKey:kCustomMetadataModelFixedChartDeleteRule];
			[persistentStoreCoordinator setMetadata:newMetadata forPersistentStore:store];
			NSLog(@"DEBUG Created new store and saved flag in metadata: %@", kCustomMetadataModelFixedChartDeleteRule);
		}
	}
	if (!happy) {
		// Really not happy.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }
	
    return persistentStoreCoordinator;
}

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
