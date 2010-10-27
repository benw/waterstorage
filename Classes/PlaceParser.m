//
//  PlaceParser.m
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

#import "PlaceParser.h"
#import "Place.h"
#import "PlaceType.h"
#import "Observation.h"
#import "Measurement.h"
#import "NSDictionary+XMLStreamParserHelpers.h"
#import "NSManagedObjectContext+Helpers.h"
#import "CalendarHelpers.h"


@interface PlaceParser ()

@property (nonatomic, retain) Place* mainPlace;
@property (nonatomic, retain) Place* identifierPlace;

@end


@implementation PlaceParser

@synthesize mainPlace = _mainPlace;
@synthesize identifierPlace = _identiferPlace;

- (void)dealloc
{
	[_mainPlace release];
	[_identifierPlace release];
	[super dealloc];
}

- (id)initWithPlace:(Place*)place context:(NSManagedObjectContext*)context
{
	if ((self = [super initWithContext:context])) {
		self.mainPlace = place;
		[self setCompleteCallback:@selector(gotIdentifier:) forElement:@"identifier"];
		[self setCompleteCallback:@selector(gotRegionOrFeature:) forElement:@"region"];
		[self setCompleteCallback:@selector(gotRegionOrFeature:) forElement:@"feature"];
		[self setCompleteCallback:@selector(gotChildren:) forElement:@"children"];
		[self setCompleteCallback:@selector(gotDailyObservations:) forElement:@"dailyObservations"];
		[self setCompleteCallback:@selector(gotDailyObservations:) forElement:@"currentDailyObservations"];
	}
	return self;
}

#pragma mark XMLStreamParser callbacks

- (void)parseError:(NSString*)errorMsg
{
	NSLog(@"PlaceParser: %@", errorMsg);
}

static NSNumber* numberFromString(NSString* string)
{
	static NSNumberFormatter* formatter = nil;
	if (formatter == nil) {
		formatter = [[NSNumberFormatter alloc] init];
		//parse . as decimal separator, regardless of default locale
		[formatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en"] autorelease]];
		[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	}
	return [formatter numberFromString:string];
}


/*
 Callbacks for parsing <region> or <feature> elements, e.g.:
 
	<region>
		<regionID>27</regionID>
		<identifier>urn:bom.gov.au:awris:common:codelist:region.city:melbourne</identifier>
		<shortName>Melbourne</shortName>
		<longName>Melbourne</longName>
		<description>Melbourne</description>
		<type>urn:bom.gov.au:awris:common:codelist:regiontype:city</type>
	</region>

	<feature>
		<featureID>3</featureID>
		<identifier>urn:bom.gov.au:awris:common:codelist:feature:thomson</identifier>
		<shortName>Thomson</shortName>
		<longName>Thomson</longName>
		<description>Thomson Reservoir is located in &lt;a href="index.html#urn:bom.gov.au:awris:common:codelist:region.state:victoria"&gt;Victoria&lt;/a&gt; and in the &lt;a href="index.html#urn:bom.gov.au:awris:common:codelist:region.drainagedivision:southeastcoast"&gt;South-East Coast&lt;/a&gt; drainage division. Thomson's primary purpose is to build up reserves in wet years for supply to Melbourne in dry years. It also provides environmental flows, releases to agriculture and water for hydro-power generation. The largest storage in Melbourne's water supply system, Thomson's size reduced the city's storage percentage full from 65% to 26% overnight when it came online on 31 July 1984.</description>
		<type>urn:bom.gov.au:awris:common:codelist:featuretype:waterstorage</type>
	</feature>
*/

- (void)gotIdentifier:(id)element
{
	if ([element isKindOfClass:[NSString class]]) {
		self.identifierPlace = [Place placeWithUrn:element context:self.context];
	} else {
		NSLog(@"Encountered <identifier> with subelements, expected string.");
	}
}

- (void)gotRegionOrFeature:(id)element
{
	if ([element isKindOfClass:[NSDictionary class]]) {
		Place *place = self.identifierPlace;
		if (place) {
			place.shortName = [element stringForKey:@"shortName"] ?: place.shortName;
			place.longName = [element stringForKey:@"longName"] ?: place.longName;
			NSString* typeUrn = [element stringForKey:@"type"];
			if (typeUrn) {
				place.type = [PlaceType placeTypeWithUrn:typeUrn context:self.context] ?: place.type;
			}
			place.loadDate = [NSDate date];
			
			//[self.context saveAndLogErrors];
		} else {
			NSLog(@"Encountered <region> or <feature> without <identifier>.");
		}

	}
	self.identifierPlace = nil;
}

- (void)gotChildren:(id)element
{
	if ([element isKindOfClass:[NSDictionary class]]) {
		[self.mainPlace addChildrenObject:self.identifierPlace];
		self.identifierPlace = nil;
	}
}


/*
 Callbacks for parsing observations, e.g.:
 
	<observations>
		<ns4:identifier>urn:bom.gov.au:awris:common:codelist:feature:thomson</ns4:identifier>
		<ns4:currentDate>2010-05-24T10:02:46</ns4:currentDate>
		<ns4:dailyObservations>
			<ns4:offset>0</ns4:offset>										// 0 = Current, 1 = Previous
			<ns4:observationDate>2010-03-29T00:00:00</ns4:observationDate>
			<ns4:totalAllocatedFeatures>0</ns4:totalAllocatedFeatures>
			<ns4:period>Day</ns4:period>									// Day, Week, Month, Year
			<ns4:volume>
				<ns4:value>228,293</ns4:value>
				<ns4:unit>ML</ns4:unit>
			</ns4:volume>
			<ns4:volumeChange>
				<ns4:value>N/A</ns4:value>
				<ns4:unit>ML</ns4:unit>
			</ns4:volumeChange>
			<ns4:percentageVolume>
				<ns4:value>21.4</ns4:value>
				<ns4:unit>%</ns4:unit>
			</ns4:percentageVolume>
			<ns4:percentageVolumeChange>
				<ns4:value>N/A</ns4:value>
				<ns4:unit>%</ns4:unit>
			</ns4:percentageVolumeChange>
			<ns4:waterLevel>
				<ns4:value>398</ns4:value>
				<ns4:unit>m</ns4:unit>
			</ns4:waterLevel>
			<ns4:waterLevelChange>
				<ns4:value>N/A</ns4:value>
				<ns4:unit>m</ns4:unit>
			</ns4:waterLevelChange>
			<ns4:waterDepth>
				<ns4:value>38</ns4:value>
				<ns4:unit>m</ns4:unit>
			</ns4:waterDepth>
			<ns4:waterDepthChange>
				<ns4:value>N/A</ns4:value>
				<ns4:unit>m</ns4:unit>
			</ns4:waterDepthChange>
			<ns4:capacity>
				<ns4:value>1,068,000</ns4:value>
				<ns4:unit>ML</ns4:unit>
			</ns4:capacity>
			<ns4:percentageObservationsMissing>
				<ns4:value>N/A</ns4:value>
				<ns4:unit>%</ns4:unit>
			</ns4:percentageObservationsMissing>
			<ns4:catchmentArea>
				<ns4:value>48,700</ns4:value>
				<ns4:unit>ha</ns4:unit>
			</ns4:catchmentArea>
			<ns4:deepestPointLevel>
				<ns4:value>N/A</ns4:value>
				<ns4:unit>m</ns4:unit>
			</ns4:deepestPointLevel>
			<ns4:fullSupplyLevel>
				<ns4:value>453.5</ns4:value>
				<ns4:unit>m</ns4:unit>
			</ns4:fullSupplyLevel>
			<ns4:fullSupplyLevelSurfaceArea>
				<ns4:value>2,230</ns4:value>
				<ns4:unit>ha</ns4:unit>
			</ns4:fullSupplyLevelSurfaceArea>
		</ns4:dailyObservations>

		<ns4:dailyObservations>
			<ns4:offset>-1</ns4:offset>
			<ns4:observationDate>2010-03-28T00:00:00</ns4:observationDate>
			<ns4:totalAllocatedFeatures>0</ns4:totalAllocatedFeatures>
			<ns4:period>Day</ns4:period>
			<ns4:volume>
				<ns4:value>228,256</ns4:value>
				<ns4:unit>ML</ns4:unit>
			</ns4:volume>
			<ns4:volumeChange>
				<ns4:value>37</ns4:value>
				<ns4:unit>ML</ns4:unit>
			</ns4:volumeChange>
			<ns4:percentageVolume>
				<ns4:value>21.4</ns4:value>
				<ns4:unit>%</ns4:unit>
			</ns4:percentageVolume>
			<ns4:percentageVolumeChange>
				<ns4:value>0</ns4:value>
				<ns4:unit>%</ns4:unit>
			</ns4:percentageVolumeChange>
			<ns4:waterLevel>
				<ns4:value>398</ns4:value>
				<ns4:unit>m</ns4:unit>
			</ns4:waterLevel>
			<ns4:waterLevelChange>
				<ns4:value>0</ns4:value>
				<ns4:unit>m</ns4:unit>
			</ns4:waterLevelChange>
			<ns4:waterDepth>
				<ns4:value>38</ns4:value>
				<ns4:unit>m</ns4:unit>
			</ns4:waterDepth>
			<ns4:waterDepthChange>
				<ns4:value>0</ns4:value>
				<ns4:unit>m</ns4:unit>
			</ns4:waterDepthChange>
			<ns4:capacity>
				<ns4:value>1,068,000</ns4:value>
				<ns4:unit>ML</ns4:unit>
			</ns4:capacity>
			<ns4:percentageObservationsMissing>
				<ns4:value>N/A</ns4:value>
				<ns4:unit>%</ns4:unit>
			</ns4:percentageObservationsMissing>
			<ns4:catchmentArea>
				<ns4:value>48,700</ns4:value>
				<ns4:unit>ha</ns4:unit>
			</ns4:catchmentArea>
			<ns4:deepestPointLevel>
				<ns4:value>N/A</ns4:value>
				<ns4:unit>m</ns4:unit>
			</ns4:deepestPointLevel>
			<ns4:fullSupplyLevel>
				<ns4:value>453.5</ns4:value>
				<ns4:unit>m</ns4:unit>
			</ns4:fullSupplyLevel>
			<ns4:fullSupplyLevelSurfaceArea>
				<ns4:value>2,230</ns4:value>
				<ns4:unit>ha</ns4:unit>
			</ns4:fullSupplyLevelSurfaceArea>
		</ns4:dailyObservations>

		...
	<observations>
*/

Measurement* measurementForElement(id element)
{
	if (element && [element isKindOfClass:[NSDictionary class]]) {
		NSString* valueString = [element objectForKey:@"value"];
		NSString* unit = [element objectForKey:@"unit"];
		if ([valueString isKindOfClass:[NSString class]] && [unit isKindOfClass:[NSString class]]) {
			NSNumber* number = numberFromString(valueString);
			if (!number) {
				return nil;
			}
			Measurement* measurement = [[[Measurement alloc] init] autorelease];
			measurement.value = [number doubleValue];
			measurement.unit = unit;
			return measurement;
		}
	}
	return nil;
}

- (void)gotDailyObservations:(id)element
{
#ifdef GET_FRESH_PLACES
	// GET_FRESH_PLACES is used to load a clean database containing
	// only Places, no observations or charts.
#else
	if (![element isKindOfClass:[NSDictionary class]]) {
		return;
	}
	
	NSString* offset = [element objectForKey:@"offset"];
	NSString* period = [element objectForKey:@"period"];
	NSString* obsKey = nil;
	if ([offset isEqualToString:@"0"]) {
		obsKey = @"obsCurrent";
	} else if ([offset isEqualToString:@"-1"]) {
		if ([period isEqualToString:@"Day"]) {
			obsKey = @"obsPreviousDay";
		} else if ([period isEqualToString:@"Week"]) {
			obsKey = @"obsPreviousWeek";
		} else if ([period isEqualToString:@"Month"]) {
			obsKey = @"obsPreviousMonth";
		} else if ([period isEqualToString:@"Year"]) {
			obsKey = @"obsPreviousYear";
		}
	}
	if (!obsKey) {
		NSLog(@"Unrecognised observations offset '%@' / period '%@'", offset, period);
		return;
	}

	Place* place = self.identifierPlace;
	Observation* obs;
	obs = [[[place valueForKey:obsKey] retain] autorelease];
	if (!obs) {
		obs = [[[Observation alloc] initWithEntity:[Observation entity] insertIntoManagedObjectContext:self.context] autorelease];
	}
	obs.observationDate = [[element objectForKey:@"observationDate"] dateFromStringISO8601DateTimeExtended];
	obs.capacity = measurementForElement([element objectForKey:@"capacity"]);
	obs.percentageVolume = measurementForElement([element objectForKey:@"percentageVolume"]);
	obs.percentageVolumeChange = measurementForElement([element objectForKey:@"percentageVolumeChange"]);
	obs.volume = measurementForElement([element objectForKey:@"volume"]);
	obs.volumeChange = measurementForElement([element objectForKey:@"volumeChange"]);
	obs.loadDate = [NSDate date];
	
	// For debug: newObs.percentageVolume.value = (random() % 1000) * 0.1f;
	
	
	[place setValue:obs forKey:obsKey];
	
	if ([obsKey isEqualToString:@"obsCurrent"]) {
		NSLog(@"%@: %@", place.longName, [place.obsCurrent.percentageVolume textAsPercentageForceSign:NO] ?: @"--.-%");
	}
	
	// [self.context saveAndLogErrors];
#endif
}


/*
 Callbacks for parsing map labels e.g.
 
	<MapLabel>
		<mapLabelID>146</mapLabelID>
		<description>Single Label for WaterStorage Map Thomson</description>
		<longitude>146.362679</longitude>
		<latitude>-37.771893</latitude>
		<identifier>urn:bom.gov.au:awris:common:codelist:feature:thomson</identifier>
	</MapLabel>
 */

- (void)gotMapLabel:(id)element
{
	if (![element isKindOfClass:[NSDictionary class]]) {
		return;
	}
	NSString* urn = [element stringForKey:@"identifier"];
	NSNumber* longitude = numberFromString([element stringForKey:@"longitude"]);
	NSNumber* latitude = numberFromString([element stringForKey:@"latitude"]);
	if (urn && longitude && latitude) {
		Place* place = [Place placeWithUrn:urn context:self.context];
		place.latitude = latitude;
		place.longitude = longitude;

		//[self.context saveAndLogErrors];
	}
}

@end
