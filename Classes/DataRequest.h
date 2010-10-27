//
//  DataRequest.h
//  Slake
//
//  Created by Ben Williamson on 31/05/10.
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

@class DataLoader;

// An abstract base class for data requests.
// Used internally by DataManager to queue and dispatch requests.

@protocol DataRequestProtocol <NSObject>

// Return a new autoreleased loader that can fulfill the request.
- (DataLoader*)makeLoader;

// YES if the condition that gave rise to the request has now been satisfied.
// e.g. If the resource has been incidentally loaded by some other request.
- (BOOL)isSatisfied;

// YES if the request should be performed even
// if isSatisfied is YES by the time this
// request reaches the front of the queue.
- (BOOL)isForceLoad;

// NO if this request is for a place that has never been loaded, YES otherwise.
- (BOOL)isClearable;

// Adopting classes must specialise NSObject's isEqual:, hash and description methods.

@end

@interface DataRequest : NSObject <DataRequestProtocol>
{
	BOOL isForceLoad;
	NSDate* requestDate;
}

@property (nonatomic) BOOL isForceLoad;
@property (nonatomic, retain) NSDate* requestDate;

@end