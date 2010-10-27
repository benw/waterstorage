//
//  Place.m
//  Slake
//
//  Created by Ben Williamson on 15/02/10.
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

#import "Place.h"
#import "PlaceType.h"
#import "DataManager.h"
#import "NSManagedObjectContext+Helpers.h"

NSString* kNewPlaceNotification = @"NewPlace";

@implementation Place

@dynamic urn;
@dynamic shortName;
@dynamic longName;
@dynamic latitude;
@dynamic longitude;
@dynamic loadDate;
@dynamic completeLoadDate;
@dynamic type;
@dynamic ascendants;
@dynamic children;
@dynamic chart;
@dynamic obsCurrent;
@dynamic obsPreviousDay;
@dynamic obsPreviousWeek;
@dynamic obsPreviousMonth;
@dynamic obsPreviousYear;

+ (Place*)placeWithUrn:(NSString*)urn context:(NSManagedObjectContext*)context
{
	assert(context);
	
	NSEntityDescription* placeEntity = [Place entity];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:placeEntity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"urn == %@", urn];
	[fetchRequest setPredicate:predicate];
	
	Place* place = nil;
	NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	if (error != nil) {
		NSLog(@"ERROR placeWithUrn:context: %@", error);
	}
	if (fetchedObjects != nil) {
		int count = [fetchedObjects count];
		if (count > 1) {
			NSLog(@"ERROR placeWithUrn:context: Store contains %d instances of %@", count, urn);
		} else if (count == 1) {
			place = [fetchedObjects lastObject];
		}
	}
	[fetchRequest release];
	
	if (place == nil) {
		place = [[[Place alloc] initWithEntity:placeEntity insertIntoManagedObjectContext:context] autorelease];
		place.urn = urn;
		[context saveAndLogErrors];
		[[NSNotificationCenter defaultCenter] postNotificationName:kNewPlaceNotification object:urn];
	}
	
	return place;
}

+ (Place*)australiaInContext:(NSManagedObjectContext*)context
{
	return [Place placeWithUrn:@"urn:bom.gov.au:awris:common:codelist:region.country:australia" context:context];
}

+ (NSEntityDescription *)entity
{
	static NSEntityDescription* entity = nil;
	
	if (entity == nil) {
		NSManagedObjectModel* model = [[DataManager manager] managedObjectModel];
		entity = [[model entitiesByName] objectForKey:@"Place"];
		[entity retain];
	}
	return entity;
}

@end
