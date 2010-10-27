//
//  DataLoader.h
//  Slake
//
//  Created by Ben Williamson on 7/06/10.
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
#import "DataRequest.h"

@class DataLoader;
@class DataParser;

@protocol DataLoaderDelegate <NSObject>

- (void)dataLoaderDidFinish:(DataLoader*)loader;

@end


@interface DataLoader : NSThread
{
	id <DataLoaderDelegate> delegate;
	NSThread* delegateThread;
	NSURLConnection* connection;
	DataParser* parser;
	NSManagedObjectContext* context;
	BOOL done;
}

@property (assign) id <DataLoaderDelegate> delegate;

// Delegate methods will by default be called on the thread that called init.
@property (assign) NSThread* delegateThread;

// The temporary context to load into.
@property (nonatomic, retain, readonly) NSManagedObjectContext* context;


// Subclasses must override these:

// The resource path to load,
// e.g. "resources/data/urn:......"
//  or  "resources/xmlchart/urn:...."
- (NSString*)resourcePath;

- (NSString*)userAgent;
// Set and return the user agent string

// This is allowed to delete stuff if the status code
// e.g. 204 or 404 indicates that the resource no longer exists.
- (BOOL)shouldContinueWithStatusCode:(NSInteger)statusCode;

// Return a new autoreleased parser that can handle the data.
- (DataParser*)makeParser;

// Called after the requested resource has completed loading successfully.
- (void)didFinishLoading;

- (void)startLoading;

// Ask the loader thread nicely to please exit very soon. Wait until it does.
// We use this to make sure the app does not exit in the middle of saving to
// a persistent store.
- (void)terminateLoading;

@end
