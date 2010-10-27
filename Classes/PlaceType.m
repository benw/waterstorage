// 
//  PlaceType.m
//  Slake
//
//  Created by Ben Williamson on 3/03/10.
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

#import "PlaceType.h"
#import "JSON/JSON.h"	// http://code.google.com/p/json-framework/
#import "NSManagedObjectContext+Helpers.h"


@implementation PlaceType 

@dynamic urn;
@dynamic singular;
@dynamic plural;
@dynamic priority;


+ (void)loadPlaceTypesInContext:(NSManagedObjectContext*)context
{
	NSString* path = [[NSBundle mainBundle] pathForResource:@"placetypes" ofType:@"json"];
	NSString* str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	id placetypesArray = [str JSONValue];
	assert(placetypesArray);
	
	for (id row in placetypesArray) {
		NSString* urn = [row valueForKey:@"urn"];
		PlaceType* placeType = [self placeTypeWithUrn:urn context:context];
		if (placeType == nil) {
			NSLog(@"Creating PlaceType %@", urn);
			NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlaceType"
													  inManagedObjectContext:context];
			placeType = [[[PlaceType alloc] initWithEntity:entity insertIntoManagedObjectContext:context] autorelease];
		}
		placeType.urn = urn;
		placeType.singular = [row valueForKey:@"singular"];
		placeType.plural = [row valueForKey:@"plural"];
		placeType.priority = [row valueForKey:@"priority"];
	}

	[context saveAndLogErrors];
}

+ (PlaceType*)placeTypeWithUrn:(NSString*)urn context:(NSManagedObjectContext*)context
{
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlaceType"
											  inManagedObjectContext:context];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"urn == %@", urn];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	if (error != nil) {
		NSLog(@"ERROR placeTypeWithUrn: %@", error);
	}
	if ([fetchedObjects count] > 1) {
		NSLog(@"ERROR %d instances of PlaceType %@", [fetchedObjects count], urn);
	}
	PlaceType* placeType = [fetchedObjects lastObject];
	if (!placeType) {
		NSLog(@"Unknown: PlaceType %@", urn);
	}
	return placeType;
}

+ (PlaceType*)countryInContext:(NSManagedObjectContext*)context
{
	return [PlaceType placeTypeWithUrn:@"urn:bom.gov.au:awris:common:codelist:regiontype:country" context:context];
}

+ (PlaceType*)stateInContext:(NSManagedObjectContext*)context
{
	return [PlaceType placeTypeWithUrn:@"urn:bom.gov.au:awris:common:codelist:regiontype:state" context:context];
}

+ (PlaceType*)drainagedivisionInContext:(NSManagedObjectContext*)context
{
	return [PlaceType placeTypeWithUrn:@"urn:bom.gov.au:awris:common:codelist:regiontype:drainagedivision" context:context];
}

+ (PlaceType*)cityInContext:(NSManagedObjectContext*)context
{
	return [PlaceType placeTypeWithUrn:@"urn:bom.gov.au:awris:common:codelist:regiontype:city" context:context];
}

+ (PlaceType*)waterstorageInContext:(NSManagedObjectContext*)context
{
	return [PlaceType placeTypeWithUrn:@"urn:bom.gov.au:awris:common:codelist:featuretype:waterstorage" context:context];
}

@end
