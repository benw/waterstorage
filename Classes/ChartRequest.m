//
//  ChartRequest.m
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

#import "ChartRequest.h"
#import "ChartLoader.h"
#import "Place.h"
#import "Chart.h"
#import "DataManager.h"


@implementation ChartRequest

@synthesize place;

- (void)dealloc
{
	[place release];
	[super dealloc];
}

- (DataLoader*)makeLoader
{
	return [[[ChartLoader alloc] initWithPlaceID:[self.place objectID]] autorelease];
}

- (BOOL)isSatisfied
{
	NSDate* date = self.place.chart.loadDate;
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
	return YES;
}

- (BOOL)isEqual:(id)other
{
	if (other == self) {
		return YES;
	}
	return [other isMemberOfClass:[ChartRequest class]]
		&& [other place] == self.place
		&& [other isForceLoad] == [self isForceLoad];
}

- (NSUInteger)hash
{
	int prime = 31;
	int result = 1;
	result = prime * result + [self.place hash];
	result = prime * result + self.isForceLoad ? 12 : 34;
	return result;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@chart for %@",
			self.isForceLoad ? @"forced " : @"",
			self.place.longName];
}

+ (ChartRequest*)chartRequestForPlace:(Place*)place force:(BOOL)force;
{
	assert([NSThread isMainThread]);
	ChartRequest* request = [[[ChartRequest alloc] init] autorelease];
	request.place = place;
	request.isForceLoad = force;
	return request;
}

@end
