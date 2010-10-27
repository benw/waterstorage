//
//  PlaceRequest.m
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

#import "PlaceRequest.h"
#import "PlaceParser.h"
#import "Place.h"
#import "Observation.h"
#import "DataManager.h"
#import "PlaceLoader.h"


@implementation PlaceRequest

@synthesize place;
@synthesize isEntireLoad;

- (void)dealloc
{
	[place release];
	[super dealloc];
}

- (DataLoader*)makeLoader
{
	NSManagedObjectID* placeID = [place objectID];
	return [[[PlaceLoader alloc] initWithPlaceID:placeID] autorelease];
}

- (BOOL)isSatisfied
{
	if (!self.place.completeLoadDate || !self.place.obsCurrent.loadDate) {
		return NO;
	}
	NSDate* date = self.place.obsCurrent.loadDate;
	if (self.isEntireLoad) {
		// The place details and current obs for all
		// the children must also be up to date.
		date = [date earlierDate:self.place.completeLoadDate];
		for (Place* child in self.place.children) {
			NSDate* childDate = child.obsCurrent.loadDate;
			if (!childDate) {
				return NO;
			}
			date = [date earlierDate:childDate];
		}
	}
	if (self.isForceLoad) {
		// Force load is satisfied if loaded since the request was made
		return NSOrderedAscending == [self.requestDate compare:date];
	} else {
		// Unforced load is satisfied if it was loaded "recently enough"
		return [DataManager dateIsRecentEnough:date];
	}
}

- (BOOL)isClearable
{
	return self.place.completeLoadDate != nil;
}

- (BOOL)isEqual:(id)other
{
	if (other == self) {
		return YES;
	}
	return [other isMemberOfClass:[PlaceRequest class]]
		&& [other place] == [self place]
		&& [other isEntireLoad] == [self isEntireLoad]
		&& [other isForceLoad] == [self isForceLoad];
}

- (NSUInteger)hash
{
	int prime = 31;
	int result = 1;
	result = prime * result + [self.place hash];
	result = prime * result + self.isForceLoad ? 12 : 34;
	result = prime * result + self.isEntireLoad ? 12 : 34;
	return result;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@%@place %@",
			self.isForceLoad ? @"forced " : @"",
			self.isEntireLoad ? @"entire " : @"",
			self.place.longName];
}

+ (PlaceRequest*)placeRequestForPlace:(Place*)place entire:(BOOL)entire force:(BOOL)force
{
	assert([NSThread isMainThread]);
	PlaceRequest* request = [[[PlaceRequest alloc] init] autorelease];
	request.place = place;
	request.isEntireLoad = entire;
	request.isForceLoad = force;
	return request;
}

@end
