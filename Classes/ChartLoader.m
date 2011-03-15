//
//  ChartLoader.m
//  Slake
//
//  Created by Ben Williamson on 8/06/10.
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

#import "ChartLoader.h"
#import "ChartParser.h"
#import "Place.h"
#import "NSManagedObjectContext+Helpers.h"


@interface ChartLoader ()	// private

@property (nonatomic, retain) NSManagedObjectID* placeID;

@end


@implementation ChartLoader

@synthesize placeID = _placeID;


- (void)dealloc
{
	[_placeID release];
	[super dealloc];
}

- (id)initWithPlaceID:(NSManagedObjectID*)placeID
{
	assert(![placeID isTemporaryID]);
	if ((self = [super init])) {
		self.placeID = placeID;
	}
	return self;
}

- (NSString*)resourcePath
{
	Place* place = (Place*)[self.context objectWithID:self.placeID];
	return [@"resources/xmlchart/" stringByAppendingString:place.urn];
}

- (BOOL)shouldContinueWithStatusCode:(NSInteger)statusCode
{
	switch (statusCode) {
		case 200:
			return YES;
			
		case 204:
		case 404:
		{
			Place* place = (Place*)[self.context objectWithID:self.placeID];
			if (place.chart)
			{
				[self.context deleteObject:place.chart];
				place.chart = nil;
				[self.context saveAndLogErrors];
			}
			return NO;
		}
			
		case 500:
			return NO;
			
		default:
			// Ever hopeful
			return YES;
	}
}

- (DataParser*)makeParser
{
	Place* place = (Place*)[self.context objectWithID:self.placeID];
	return [[[ChartParser alloc] initWithPlace:place context:self.context] autorelease];
}

- (void)didFinishLoading
{
}

@end
