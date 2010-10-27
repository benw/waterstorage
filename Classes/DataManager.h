//
//  DataManager.h
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

#import <Foundation/Foundation.h>
#import "DataLoader.h"

@class Place;
@protocol DataRequestProtocol;
@class Reachability;
@class DataLoader;

/**
 * The DataManager class is a singleton which is responsible
 * for loading data from the server. Requests to load
 * places and charts are queued, and loading is asynchronous
 * in that data will be loaded some time after loadPlace / loadChart
 * has returned. DataManager also manages the network activity indicator.
 */
@interface DataManager : NSObject <DataLoaderDelegate>
{
	id <DataRequestProtocol> requestInProgress;
	DataLoader* loaderInProgress;
	Reachability* reachability;
	BOOL networkAlertHasBeenShown;
	
	// A queue of id <DataRequestProtocol>. Each is loaded when it reaches index 0.
	NSMutableArray* queue;

	NSManagedObjectContext* rootContext;
	NSManagedObjectModel *managedObjectModel;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

// Get the singleton.
+ (DataManager*)manager;

// The full base url with the protocol to access water storage resources
+ (NSString*)baseUrl;

// Convenience method for checking if loadDates have expired.
// YES if date is non-nil and within the last hour.
+ (BOOL)dateIsRecentEnough:(NSDate*)date;

// Scans for places which have not been completely loaded, and loads them.
- (void)loadAllNewPlaces;

// Queues a place to be loaded.
//
// entire is YES if the place's URN must be loaded directly to satisfy the request,
// or NO if the request can be satisfied incidentally by encountering a description of the place
// while loading some other place.
//
// If force is YES then the place is loaded even if it seems to be up to date.
// If force is NO then the place is loaded only if not loaded recently.
- (void)loadPlace:(Place*)place entire:(BOOL)entire force:(BOOL)force;

// Queues a chart to be loaded.
//
// If force is YES then the chart is loaded even if it seems to be up to date.
// If force is NO then the chart is loaded only if not loaded recently.
- (void)loadChartForPlace:(Place*)place force:(BOOL)force;

// Clear the queue.
//
// It is appropriate to call this when the user switches to a new view,
// where it is more important to load the newly-visible stuff.
// This does not affect the currently active request's connection,
// and does not dequeue requests to load places that have never been
// completely loaded.
- (void)clearQueue;

// YES if the data server is reachable,
- (BOOL)serverIsReachable;

// Call this when the user explicitly requests data, using shake-to-reload.
// If there is no network connection, it pops a network alert.
- (void)explicitLoadRequested;

// Ask the loader thread nicely to please exit very soon. Wait until it does.
// The request in progress is requeued at the head of the queue, so that
// it can be resumed with resumeLoading.
- (void)suspendLoading;

// Kick off loading whatever is sitting in the queue. Only neccessary after
// calling suspendLoading.
- (void)resumeLoading;

// The root managed object context.
- (NSManagedObjectContext*)rootContext;

- (NSManagedObjectModel*)managedObjectModel;
- (NSPersistentStoreCoordinator*)persistentStoreCoordinator;

@end
