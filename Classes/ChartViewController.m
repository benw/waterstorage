//
//  ChartViewController.m
//  Slake
//
//  Created by Ben Williamson on 4/05/10.
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

#import "ChartViewController.h"
#import "Chart.h"
#import "ChartSeries.h"
#import "ChartDataset.h"
#import "ChartValue.h"
#import "ChartObservation.h"
#import "Measurement.h"
#import "Place.h"
#import "Observation.h"
#import "CalendarHelpers.h"

@interface ChartViewController ()	// private

@property (nonatomic, retain) CPXYGraph* graph;
@property (nonatomic, retain) CPScatterPlot* markerPlot;
//marker
@property (nonatomic) int xCoordinate;
@property (nonatomic) float viewXPosition;
@property (nonatomic, retain) NSMutableArray* yCoordinates;

- (void)updateChart:(Chart*)chart;

- (void)createPlotSpace;

@end


@implementation ChartViewController

//percentage value at the top of the visible chart view
CGFloat const kChartTopYValue = 1.1f;

//Invisible negative padding to fix a plot rendering issue.
//Anything over kChartTopYValue is not visible but still drawn so that the
//gradient below the plot is not broken
CGFloat const kMaxYValue = 4.0f;

@synthesize graph;
@synthesize markerPlot = _markerPlot;
@synthesize xCoordinate = _xCoordinate;
@synthesize viewXPosition = _viewXPosition;
@synthesize yCoordinates = _yCoordinates;
@synthesize chartDelegate = _chartDelegate;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[graph release];
	[place release];
	[_markerPlot release];
	[_yCoordinates release];
	[super dealloc];
}


- (void)setPlace:(Place *)newPlace
{
	if (newPlace != place)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:NSManagedObjectContextObjectsDidChangeNotification
													  object:[place managedObjectContext]];
		[place release];
		place = [newPlace retain];
		_chart = place.chart;
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(objectsDidChangeNotification:)
													 name:NSManagedObjectContextObjectsDidChangeNotification
												   object:[place managedObjectContext]];
	}
}


- (Place*)place
{
	return place;
}


- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.graph = nil;
	self.markerPlot = nil;
	self.yCoordinates = nil;
}


- (void)objectsDidChangeNotification:(NSNotification*)notification
{
	NSDictionary* userInfo = [notification userInfo];
	NSSet* refreshed = [userInfo objectForKey:NSRefreshedObjectsKey];
	NSSet* updated = [userInfo objectForKey:NSUpdatedObjectsKey];
	if ([refreshed containsObject:place] || [updated containsObject:place]) {
		if (_chart != place.chart) {
			_chart = place.chart;
			[self updateChart:place.chart];
		}
	}
}


- (void)updateChart:(Chart*)chart
{
	assert([NSThread isMainThread]);
	
	//remove existing plots
	for (CPPlot* plot in [self.graph allPlots])
	{
		[self.graph removePlot:plot];
	}
	//discard potential marker
	self.markerPlot = nil;
	[self.markerLabelDelegate hideLabels];
	
	double red = 0.0/255;
	double green = 186.0/255;
	double blue = 255.0/255;
	
	NSInteger currentYear = [[[NSCalendar gregorian] components:NSYearCalendarUnit fromDate:chart.xEnd] year];
	NSSortDescriptor *yearDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"year" ascending:NO] autorelease];
	NSArray* orderedSeries = [[chart.series allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:yearDescriptor]];
	for (ChartSeries* series in orderedSeries)
	{
		float alpha = 0.0f;
		int year = [series.year intValue];
		if (year == currentYear)
		{
			alpha = 1.0f;
		}
		else if (year == currentYear - 1)
		{
			alpha = 0.35f;
		}
		else if (year == currentYear - 2)
		{
			alpha = 0.15f;
		}
		else
		{
			continue;
		}

		CPColor* topPlotColor = [CPColor colorWithComponentRed:red green:green blue:blue alpha:alpha-0.15];
		CPColor* bottomPlotColor = [CPColor colorWithComponentRed:red green:green blue:blue alpha:alpha-0.3];
		CPColor* lineColor = [CPColor colorWithComponentRed:1.0 green:1.0 blue:1.0 alpha:alpha];
		for (ChartDataset* dataset in series.datasets)
		{
			CPScatterPlot *plot = [[[CPScatterPlot alloc] initWithFrame:CGRectNull] autorelease];
			plot.dataLineStyle.lineColor = lineColor;
			plot.dataLineStyle.lineWidth = 2.0f;
			plot.dataSource = dataset;
			
			CPGradient* plotGradient = [[[CPGradient alloc] init] autorelease];
			plotGradient = [plotGradient addColorStop:topPlotColor atPosition:0];
			plotGradient = [plotGradient addColorStop:bottomPlotColor atPosition:1];
			plotGradient.angle = 270.0f;
			CPFill* plotGradientFill = [CPFill fillWithGradient:plotGradient];
			plot.areaFill = plotGradientFill;
			plot.areaBaseValue = CPDecimalFromString(@"0.0");
			
			[self.graph addPlot:plot];
		}
	}
	[self.chartDelegate chartUpdated];
}


- (void)createPlotSpace
{
	CPXYPlotSpace* plotSpace = (CPXYPlotSpace *)self.graph.defaultPlotSpace;
	plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInteger(1)
												   length:CPDecimalFromInteger(366)];
	plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0f)
												   length:CPDecimalFromFloat(kMaxYValue)];
	
	CPColor* colorAxis = [CPColor colorWithComponentRed:210.0/255 green:240.0/255 blue:255/255 alpha:1];
	CPLineStyle* lineStyle = [CPLineStyle lineStyle];
	lineStyle.lineColor = colorAxis;
	lineStyle.lineWidth = 2.0f;
	
	CPXYAxisSet* axisSet = (CPXYAxisSet*)self.graph.axisSet;
	
	CPLineStyle* invisibleLineStyle = [CPLineStyle lineStyle];
	invisibleLineStyle.lineWidth = 0.0f;
	
	CPXYAxis* x = axisSet.xAxis;
	x.labelTextStyle.color = [CPColor clearColor];
	x.minorTicksPerInterval = 0;
	x.majorTickLength = 0.0f;
	x.axisLineStyle = invisibleLineStyle;
	x.labelingPolicy = CPAxisLabelingPolicyLocationsProvided;
	CPLineStyle* thinLineStyle = [CPLineStyle lineStyle];
	//Hack: this dash pattern is exactly the length from 0 to 100% in landscape, it needs to be adjusted with plot space size
	thinLineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:205.0f], [NSNumber numberWithFloat:100.0f], nil];
	thinLineStyle.lineColor = [CPColor colorWithComponentRed:204.0f/255.0f green:204.0f/255.0f blue:1.0f alpha:0.2f];
	thinLineStyle.lineWidth = 1.0f;
	x.majorGridLineStyle = thinLineStyle;
	
	x.visibleRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInteger(1) length:CPDecimalFromInteger(366)];
	
	CPXYAxis *y = axisSet.yAxis;
	y.labelTextStyle.color = [CPColor clearColor];
	y.orthogonalCoordinateDecimal = CPDecimalFromString(@"1");
	y.labelingPolicy = CPAxisLabelingPolicyLocationsProvided;
	y.majorTickLength = 0.0f;
	CPLineStyle* dottedLineStyle = [CPLineStyle lineStyle];
	dottedLineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1.0f], [NSNumber numberWithFloat:4.0f], nil];
	dottedLineStyle.lineColor = [CPColor colorWithComponentRed:204.0f/255.0f green:204.0f/255.0f blue:1.0f alpha:0.5f];
	dottedLineStyle.lineWidth = 1.0f;
	y.majorGridLineStyle = dottedLineStyle;
	y.axisLineStyle = invisibleLineStyle;
	
	y.visibleRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInteger(0) length:CPDecimalFromInteger(1)];
}


-(void)setYAxisSetTickLocations:(NSSet*)locations
{
	CPXYAxisSet* axisSet = (CPXYAxisSet*)self.graph.axisSet;
	axisSet.yAxis.majorTickLocations = locations;
}


-(void)setXAxisSetTickLocations:(NSSet*)locations
{
	CPXYAxisSet* axisSet = (CPXYAxisSet*)self.graph.axisSet;
	axisSet.xAxis.majorTickLocations = locations;
}


-(void)setXAxisRangeFrom:(float)start length:(float)length
{
	CPXYPlotSpace* plotSpace = (CPXYPlotSpace *)self.graph.defaultPlotSpace;
	plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(start)
												   length:CPDecimalFromFloat(length)];
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	//NSLog(@"viewWillAppear, for place: %@", self.place);
	[self updateChart:place.chart];
}


- (void)linkGraphToHostedLayer
{
	CPLayerHostingView* hostingView = (CPLayerHostingView*)self.view;
	hostingView.hostedLayer = self.graph;
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	//NSLog(@"view did load");
	//CorePlot chart rendering
	self.graph = [[[CPXYGraph alloc] initWithFrame:CGRectZero] autorelease];
	
	self.graph.paddingLeft = 0.0f;
	self.graph.paddingBottom = 0.0f;
	self.graph.paddingRight = 0.0f;
	self.graph.paddingTop = 0.0f;
	
	self.graph.plotAreaFrame.paddingLeft = 0.0f;
	self.graph.plotAreaFrame.paddingBottom = 0.0f;
	self.graph.plotAreaFrame.paddingRight = 0.0f;
	self.graph.plotAreaFrame.paddingTop = (kChartTopYValue - kMaxYValue) / kChartTopYValue * self.view.frame.size.height;
	
	//create background
	CPGradient *backgroundGradient = [[[CPGradient alloc] init] autorelease];
	CPColor* topBackgroundColor = [CPColor colorWithComponentRed:9.0/255.0 green:102.0/255.0 blue:180.0/255.0 alpha:1.0];
	CPColor* bottomBackgroundColor = [CPColor colorWithComponentRed:4.0/255.0 green:77.0/255.0 blue:123.0/255.0 alpha:1.0];
	backgroundGradient = [backgroundGradient addColorStop:topBackgroundColor atPosition:0.0];
	backgroundGradient = [backgroundGradient addColorStop:bottomBackgroundColor atPosition:1.0];
	backgroundGradient.angle = 270.0;
	self.graph.plotAreaFrame.fill = [CPFill fillWithGradient:backgroundGradient];
	//NSLog(@"graph view created");
	[self createPlotSpace];
}


- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)setMarkerLabelDelegate:(id <MarkerLabelDelegate>)delegate
{
	if (delegate)
	{
		self.graph.defaultPlotSpace.delegate = self;
	}
	else
	{
		self.graph.defaultPlotSpace.delegate = nil;
	}
	_markerLabelDelegate = delegate;
}


- (id <MarkerLabelDelegate>)markerLabelDelegate
{
	return _markerLabelDelegate;
}


- (void)updateMarkerValues
{
	Chart* chart = self.place.chart;

	NSCalendar* gregorian = [NSCalendar gregorian];
	NSInteger currentYear = [[gregorian components:NSYearCalendarUnit fromDate:chart.xEnd] year];
	
	//WARNING Assert that unit is volume, can only be checked from yAxisLabel in parenthesis based on current chart XML format
	NSString* volumeUnit = place.obsCurrent.capacity.unit ?: @"ML";
	
	NSMutableArray* observations = [NSMutableArray arrayWithCapacity:3];
	self.yCoordinates = [NSMutableArray arrayWithCapacity:3+2];
	[self.yCoordinates addObject:[NSNumber numberWithInt:-10]];
	for (NSInteger yearIndex = currentYear; yearIndex > currentYear - 3; yearIndex--)
	{
		NSPredicate* predicate = [NSPredicate predicateWithFormat:@"year == %@", [NSNumber numberWithInt:yearIndex]];
		ChartSeries* yearSeries = [[chart.series filteredSetUsingPredicate:predicate] anyObject];
		
		NSDateComponents* dateComps = [[[NSDateComponents alloc] init] autorelease];
		[dateComps setYear:yearIndex];
		if (self.xCoordinate > 31 + 28 && ![NSCalendar isLeapYear:yearIndex]) {
			[dateComps setDay:self.xCoordinate - 1];
		} else {
			[dateComps setDay:self.xCoordinate];
		}
		
		NSDate* date = [gregorian dateFromComponents:dateComps];
		ChartValue* yearValue = [yearSeries getValueForDayInYear:self.xCoordinate];
		
		Measurement* percentageVolume = nil;
		Measurement* volume = nil;
		if (yearValue) {
			percentageVolume = [Measurement measurementWithUnit:@"%" value:yearValue.percentage * 100.0];
			volume = [Measurement measurementWithUnit:volumeUnit value:yearValue.value];
			[(NSMutableArray*)self.yCoordinates addObject:[NSNumber numberWithDouble:yearValue.percentage]];
		}
		[observations addObject:[ChartObservation chartObservationWithDate:date
														  percentageVolume:percentageVolume
																	volume:volume]];
	}
	[self.yCoordinates addObject:[NSNumber numberWithInt:10]];
	[self.markerLabelDelegate showLabelsForChartObservations:observations awayFrom:self.viewXPosition];
}

-(CGPoint)viewCoordinatesForChartPoint:(NSDecimal*)chartPoint
{
	/*NSLog(@"chartPoint: %f, %f", [[NSDecimalNumber decimalNumberWithDecimal:chartPoint[0]] floatValue],
		  [[NSDecimalNumber decimalNumberWithDecimal:chartPoint[1]] floatValue]);*/
	CGPoint pointInPlotArea = [self.graph.defaultPlotSpace plotAreaViewPointForPlotPoint:chartPoint];
	//NSLog(@"pointInPlotArea: %f,%f", pointInPlotArea.x, pointInPlotArea.y);
	CGPoint pointInView = [self.graph convertPoint:pointInPlotArea fromLayer:self.graph.plotAreaFrame]; //or self.graph.defaultPlotSpace.plotArea ?
	//NSLog(@"pointInView: %f,%f", pointInView.x, pointInView.y);
	return pointInView;
}	

#pragma mark CPPlotSpaceDelegate protocol

-(BOOL)plotSpace:(CPPlotSpace *)space shouldHandlePointingDeviceDownEvent:(id)event atPoint:(CGPoint)point
{
	/*NSLog(@"shouldHandlePointingDeviceDownEvent\nevent=%@\npoint=(%f, %f)", event, point.x, point.y);
	NSLog(@"bounds (%f,%f) (%f,%f)", self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
	NSLog(@"frame (%f,%f) (%f,%f)", self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);*/
	//WARNING coreplot plotAreaFrame translation is incorrect if paddings are used
	CGPoint pointInPlotArea = [self.graph convertPoint:point toLayer:self.graph.plotAreaFrame];	
	
	NSDecimal newPoint[2];
	[self.graph.defaultPlotSpace plotPoint:newPoint forPlotAreaViewPoint:pointInPlotArea];
	NSDecimalRound(&newPoint[0], &newPoint[0], 0, NSRoundPlain);
	int x = [[NSDecimalNumber decimalNumberWithDecimal:newPoint[0]] intValue];
	
	//NSLog(@"x=%d", x);
	if (x<1) {x = 1;}
	else if (x>366) {x = 366;}
	/*NSLog(@"coordinates point: (%f, %f) pointInPlotArea: (%f, %f)", 
		  point.x, point.y, 
		  pointInPlotArea.x, pointInPlotArea.y);
	NSLog(@"touch down at: %f, %f (point: %f, %f)", 
		  [[NSDecimalNumber decimalNumberWithDecimal:newPoint[0]] doubleValue], 
		  [[NSDecimalNumber decimalNumberWithDecimal:newPoint[1]] doubleValue],
		  point.x, 
		  point.y);*/
	
	if (self.markerPlot)
	{
		[self.graph removePlot:self.markerPlot];
	}
	self.markerPlot = [[[CPScatterPlot alloc] 
						initWithFrame:CGRectNull] autorelease];
	self.xCoordinate = x;
	self.viewXPosition = point.x;
	
	CPColor* yellow = [CPColor colorWithComponentRed:0.9 green:0.80 blue:0.05 alpha:1.0];
	[self updateMarkerValues];
	
	CPLineStyle *symbolLineStyle = [CPLineStyle lineStyle];
	symbolLineStyle.lineColor = yellow;
	CPPlotSymbol *plotSymbol = [CPPlotSymbol ellipsePlotSymbol];
	plotSymbol.fill = [CPFill fillWithColor:yellow];
	plotSymbol.lineStyle = symbolLineStyle;
	plotSymbol.size = CGSizeMake(6.0, 6.0);
	_markerPlot.plotSymbol = plotSymbol;
	
	_markerPlot.dataLineStyle.lineColor = yellow;
	_markerPlot.dataLineStyle.lineWidth = 2.5f;
	_markerPlot.dataSource = self;
	
	[self.graph addPlot:_markerPlot];
	return YES;
}

-(BOOL)plotSpace:(CPPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(id)event atPoint:(CGPoint)point
{
	/*NSLog(@"shouldHandlePointingDeviceDraggedEvent\nevent=%@\npoint=(%f, %f)", event, point.x, point.y);*/
	if (self.markerPlot)
	{
		CGPoint pointInPlotArea = [self.graph convertPoint:point toLayer:self.graph.plotAreaFrame];
		NSDecimal newPoint[2];
		[self.graph.defaultPlotSpace plotPoint:newPoint forPlotAreaViewPoint:pointInPlotArea];
		/*NSLog(@"touch dragged to: %f, %f", 
			  [[NSDecimalNumber decimalNumberWithDecimal:newPoint[0]] doubleValue], 
			  [[NSDecimalNumber decimalNumberWithDecimal:newPoint[1]] doubleValue]);*/
		NSDecimalRound(&newPoint[0], &newPoint[0], 0, NSRoundPlain);
		int x = [[NSDecimalNumber decimalNumberWithDecimal:newPoint[0]] intValue];
		
		//NSLog(@"pos=%f val=%f  x=%d", point.x, [[NSDecimalNumber decimalNumberWithDecimal:newPoint[0]] doubleValue], x);
		if (x<1) {x = 1;}
		else if (x>366) {x = 366;}
		
		if (self.xCoordinate != x) {
			self.xCoordinate = x;
			self.viewXPosition = point.x;
			[self updateMarkerValues];
			[self.markerPlot reloadData];
		}
	}
	return YES;
}


-(BOOL)plotSpace:(CPPlotSpace *)space shouldHandlePointingDeviceCancelledEvent:(id)event
{
	/*NSLog(@"shouldHandlePointingDeviceCancelledEvent\nevent=%@", event);
	NSLog(@"touch cancelled, plot was drawn: %@", self.markerPlot ? @"YES" : @"NO");*/
	if (self.markerPlot)
	{
		[self.graph removePlot:self.markerPlot];
		self.markerPlot = nil;
		[self.markerLabelDelegate hideLabels];
	}
	return YES;
}


-(BOOL)plotSpace:(CPPlotSpace *)space shouldHandlePointingDeviceUpEvent:(id)event atPoint:(CGPoint)point
{
	/*NSLog(@"shouldHandlePointingDeviceUpvent\nevent=%@\npoint=(%f, %f)", event, point.x, point.y);*/
	if (self.markerPlot)
	{
		[self.graph removePlot:self.markerPlot];
		self.markerPlot = nil;
		[self.markerLabelDelegate hideLabels];
	}
	return YES;
}


#pragma mark CPPlotDataSource protocol


-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot
{
	return [self.yCoordinates count];
}


-(NSArray*)numbersForPlot:(CPPlot*)plot field:(NSUInteger)fieldEnum  
		 recordIndexRange:(NSRange)indexRange
{
	if (fieldEnum == CPScatterPlotFieldX)
	{
		NSMutableArray* result = [NSMutableArray arrayWithCapacity:[self.yCoordinates count]];
		for (int i=0; i<[self.yCoordinates count]; i++) {
			[result addObject:[NSNumber numberWithInt:_xCoordinate]];
		}
		return result;
	} else {
		//CPScatterPlotFieldY
		return self.yCoordinates;
	}
}

@end
