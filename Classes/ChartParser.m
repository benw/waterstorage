//
//  ChartParser.m
//  Slake
//
//  Created by Quentin Leseney on 11/05/10.
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

#import "ChartParser.h"
#import "Chart.h"
#import "ChartSeries.h"
#import "ChartDataset.h"
#import "ChartValue.h"
#import "Place.h"
#import "Observation.h"
#import "Measurement.h"
#import "NSManagedObjectContext+Helpers.h"
#import "CalendarHelpers.h"


@interface ChartParser ()	// private

@property (nonatomic, retain) Place* place;

@property (nonatomic, retain) NSDateFormatter* dateFormatter;
@property (nonatomic, retain) NSNumberFormatter* numberFormatter;
@property (nonatomic, retain) Chart* chart;
@property (nonatomic, retain) ChartSeries* currentSeries;
@property (nonatomic) int currentDayInYear; // 0 when start date not set
@property (nonatomic) BOOL incorrectValueInDataset;// when gap potentially required the creation a new dataset
@property (nonatomic, retain) NSMutableArray* values; // current dataset values

- (NSDate*)dateFromString:(NSString*)string;
- (NSNumber*)numberFromString:(NSString*)string;

@end


@implementation ChartParser

@synthesize place = _place;
@synthesize dateFormatter = _dateFormatter;
@synthesize numberFormatter = _numberFormatter;
@synthesize chart = _chart;
@synthesize currentSeries = _currentSeries;
@synthesize currentDayInYear = _currentDayInYear;
@synthesize incorrectValueInDataset = _incorrectValueInDataset;
@synthesize values = _values;

- (void)dealloc
{
	[_place release];
	[_dateFormatter release];
	[_numberFormatter release];
	[_chart release];
	[_currentSeries release];
	[_values release];
	[super dealloc];
}

- (id)initWithPlace:(Place*)place context:(NSManagedObjectContext*)context
{
	if ((self = [super initWithContext:context])) {
		self.place = place;
		
		self.numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
		self.numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
		//parse . as decimal separator, regardless of default locale
		self.numberFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en"] autorelease];
		self.currentDayInYear = 0;
		
		[self setStartCallback:@selector(startChart:) forElement:@"chart"];
		[self setCompleteCallback:@selector(gotChart:) forElement:@"chart"];
		[self setCompleteCallback:@selector(gotConfiguration:) forElement:@"configuration"];
		[self setStartCallback:@selector(startSeries:) forElement:@"series"];
		[self setCompleteCallback:@selector(gotSeries:) forElement:@"series"];
		[self setStartCallback:@selector(startDataset:) forElement:@"dataset"];
		[self setCompleteCallback:@selector(gotDataset:) forElement:@"dataset"];
		[self setCompleteCallback:@selector(gotStartDate:) forElement:@"startdate"];
		[self setCompleteCallback:@selector(gotRecord:) forElement:@"record"];
	}
	return self;
}

// Robust against "string" argument that is not actually an NSString.
- (NSDate*)dateFromString:(NSString*)string
{
	if ([string isKindOfClass:[NSString class]]) {
		return [self.dateFormatter dateFromString:string];
	} else {
		return nil;
	}
}

// Robust against "string" argument that is not actually an NSString.
- (NSNumber*)numberFromString:(NSString*)string
{
	if ([string isKindOfClass:[NSString class]]) {
		return [self.numberFormatter numberFromString:string];
	} else {
		return nil;
	}
}

#pragma mark XML file example

/*
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<chart>
	<configuration>
		<dateformat>yyyyMMdd</dateformat>
		<yAxisLabel>Stored Volume (ML)</yAxisLabel>
		<xStart>20100301</xStart>
		<xEnd>20100511</xEnd>
		<yMin>0</yMin>
		<yMax>1094839</yMax>
	</configuration>
	<series>
		<name>2010</name>
		<interval>
			<unit>day</unit>
			<value>1</value>
		</interval>
		<dataset>
			<startdate>20100301</startdate>
			<record>24014.112</record>
			<record>23924.32</record>
		</dataset>
		<dataset>
			<startdate>20100323</startdate>
			<record>227077.5</record>
			<record>227188.2</record>
			<record>227253.2</record>
			<record>227271.7</record>
			<record>106.061</record>
		</dataset>
	</series>
	<series>
		<name>2009</name>
		<interval>
			<unit>day</unit>
			<value>1</value>
		</interval>
	</series>
</chart>
*/


#pragma mark XMLStreamParser callbacks

- (void)startChart:(NSString*)elementName
{
	self.chart = [NSEntityDescription
				 insertNewObjectForEntityForName:@"Chart"
				 inManagedObjectContext:self.context];
}

- (void)gotConfiguration:(id)element
{
	NSString* dateformat = [element objectForKey:@"dateformat"];
	if ([dateformat isKindOfClass:[NSString class]]) {
		self.dateFormatter = [NSDateFormatter dateFormatterWithFormat:dateformat];
	}
	else {
		self.dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"yyyyMMdd"];
	}

	self.chart.xStart = [self dateFromString:[element objectForKey:@"xStart"]];
	self.chart.xEnd = [self dateFromString:[element objectForKey:@"xEnd"]];
	self.chart.yMin = [self numberFromString:[element objectForKey:@"yMin"]];
	self.chart.yMax = [self numberFromString:[element objectForKey:@"yMax"]];
	NSString* yAxislabel = [element objectForKey:@"yAxisLabel"];
	NSString* unit = self.place.obsCurrent.capacity.unit;
	if (unit && [yAxislabel rangeOfString:unit].location == NSNotFound)
	{
		NSLog(@"Warning: Unit of capacity in observation (%@) not found in chart y axis label \"%@\", values may be inconsistent", unit, yAxislabel);
	}
}

- (void)startSeries:(NSString*)elementName
{
	if (!self.chart) {
		NSLog(@"Malformed XML chart: found <series> tag outside <chart>");
	} else if (!self.dateFormatter) {
		NSLog(@"Malformed XML chart: found <series> tag but no configuration has been found");
	} else {
		if (self.currentSeries) {
			NSLog(@"Malformed XML chart: found starting <series> tag while previous series missing closing </series> tag");
			[self.context deleteObject:self.currentSeries];
			self.values = nil;
			self.currentDayInYear = 0;
		}
		self.currentSeries = [NSEntityDescription
							  insertNewObjectForEntityForName:@"ChartSeries"
							  inManagedObjectContext:self.context];
	}
}

- (void)gotSeries:(id)element
{
	//unused [element objectForKey:@"title"]
	if (!self.currentSeries) {
		NSLog(@"Malformed XML chart: found closing </series> tag without matching starting <series> tag");
	} else if (![element isKindOfClass:[NSDictionary class]]) {
		NSLog(@"Malformed XML chart: no <interval> defined in series");
		[self.context deleteObject:self.currentSeries];
	} else {
		NSDictionary* interval = [element objectForKey:@"interval"];
		if (![interval isKindOfClass:[NSDictionary class]]) {
			NSLog(@"Malformed XML chart: incorrect <interval> structure");
			[self.context deleteObject:self.currentSeries];
		} else {
			NSString* unit = [interval objectForKey:@"unit"];
			NSNumber* value = [self numberFromString:[interval objectForKey:@"value"]];
			if (![unit isKindOfClass:[NSString class]] ||
				![unit isEqualToString:@"day"] ||
				![value isKindOfClass:[NSNumber class]] ||
				![value isEqualToNumber:[NSNumber numberWithInt:1]])
			{
				NSLog(@"Malformed XML chart: incorrect <interval> structure, expecting 1-day interval");
				[self.context deleteObject:self.currentSeries];
			} else {
				[self.chart addSeriesObject:self.currentSeries];
			}
		}
	}
	self.currentSeries = nil;
}

- (void)startDataset:(NSString*)elementName
{
	self.values = [[[NSMutableArray alloc] init] autorelease];
	self.incorrectValueInDataset = NO;
}

- (void)gotDataset:(id)element
{
	if (self.currentSeries) {
		ChartDataset* dataset = [NSEntityDescription
							   insertNewObjectForEntityForName:@"ChartDataset"
							   inManagedObjectContext:self.context];
		dataset.values = self.values;
		self.values = nil;
		self.currentDayInYear = 0;
		[self.currentSeries addDatasetsObject:dataset];
	}
}

- (void)gotStartDate:(id)element
{
	if (!self.chart || !self.currentSeries || self.currentDayInYear != 0)
	{
		NSLog(@"Malformed XML chart: unexpected <startDate> tag");
	} else {
		NSDate* date = [self dateFromString:element];
		NSCalendar* gregorian = [NSCalendar gregorian];
		int year = [[gregorian components:NSYearCalendarUnit fromDate:date] year];
		int day = [gregorian ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:date];
		if (self.currentDayInYear >= 31 + 28 + 1 && ![NSCalendar isLeapYear:[self.currentSeries.year intValue]]) {
			day++;
		}
		self.currentDayInYear = day;
		if (self.currentSeries.year && year != [self.currentSeries.year intValue]) {
			NSLog(@"Malformed XML chart: incorrect year for <startDate> in series");
			self.currentDayInYear = 0;
		} else {
			self.currentSeries.year = [NSNumber numberWithInt:year];
		}
	}
}

- (void)gotRecord:(id)element
{
	if (!self.chart || !self.currentSeries) {
		NSLog(@"Malformed XML chart: unexpected <record> tag");
	} else if (self.currentDayInYear == 0) {
		NSLog(@"Malformed XML chart: <record> found without startDate set");
	} else if (self.values && self.chart.yMax) {
		NSNumber* number = [self numberFromString:element];
		//only add correct values
		if (number) {
			ChartValue* value = [[[ChartValue alloc] init] autorelease];
			value.dayInYear = self.currentDayInYear;
			value.value = [number doubleValue];
			double yMax = [self.chart.yMax doubleValue];
			value.percentage = (yMax == 0.0) ? 0.0 : value.value / yMax;
			if (self.incorrectValueInDataset) {
				//if incorrect value found, start a new dataset to keep day contiguity
				ChartDataset* dataset = [NSEntityDescription
										 insertNewObjectForEntityForName:@"ChartDataset"
										 inManagedObjectContext:self.context];
				dataset.values = self.values;
				[self.currentSeries addDatasetsObject:dataset];
				self.values = [[[NSMutableArray alloc] init] autorelease];
				self.incorrectValueInDataset = NO;
			}
			[self.values addObject:value];
		} else {
			//only deal with it only if more values in this dataset
			self.incorrectValueInDataset = YES;
		}
		self.currentDayInYear++;
		if (self.currentDayInYear == 31 + 28 + 1 && ![NSCalendar isLeapYear:[self.currentSeries.year intValue]]) {
			//add the 28 Feb value again to fill in the gap
			[self gotRecord:element];
		}
	}
}

- (void)gotChart:(id)element
{
	if (!self.chart)
	{
		NSLog(@"Malformed XML chart: unexpected closing </chart> tag");
	} else {
		self.chart.loadDate = [NSDate date];
		
		Chart* oldChart = self.place.chart;
		if (oldChart) {
			[self.context deleteObject:oldChart];
		}
		self.place.chart = self.chart;
		[self.context saveAndLogErrors];
		
		self.place = nil;
		self.chart = nil;
		self.currentSeries = nil;
		self.values = nil;
		self.dateFormatter = nil;
		self.numberFormatter = nil;
	}
}

@end
