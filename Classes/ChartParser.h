//
//  ChartParser.h
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
//  This parser reads an XML file representing data values for dates.
//  The structure is a chart contains a number of series, each series containing values for a year.
//  A series can be decomposed in datasets containing values for contiguous days.
//
//  Specifities:
//  * The XML structure defined that values are reported for regular intervals.
//    This parser requires that the interval is one day.
//  * Each series must contain values that are only in the same year
//  * Because year series are viewed stacked on a horizontal axis ranging from 1 Jan to 31 Dec and
//    some years are leap years, the output model contains 366 values for any year, 
//    where the value for 28 Feb is duplicated to fill in the 29 Feb gap.
//  * If some data values are incorrect, gaps can result within a parsed dataset. 
//    In that case new datasets are created in the output model keep day contiguity.
//  * Percentages used in the output model for a value are the value divided by the chart yMax value

#import "Chart.h"
#import "DataParser.h"
#import "ChartSeries.h"
#import "ChartDataset.h"

@class ChartParser;
@class Place;

@interface ChartParser : DataParser
{
@private
	Place* _place;
	NSDateFormatter* _dateFormatter;
	NSNumberFormatter* _numberFormatter;
	Chart* _chart;
	ChartSeries* _currentSeries;
	int _currentDayInYear;
	BOOL _incorrectValueInDataset;
	NSMutableArray* _values;	// Array of ChartValues
}

- (id)initWithPlace:(Place*)place context:(NSManagedObjectContext*)context;

@end
