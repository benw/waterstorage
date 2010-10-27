//
//  PlaceDetailViewController.m
//  Slake
//
//  Created by Ben Williamson on 11/02/10.
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

#import "PlaceDetailViewController.h"
#import "Place.h"
#import "Chart.h"
#import "PlaceType.h"
#import "Observation.h"
#import "Measurement.h"
#import "PlaceCell.h"
#import "FavouriteToggleButtonController.h"
#import "FancyLabel.h"
#import "DataManager.h"
#import "ChartViewController.h"
#import "LandscapeViewController.h"
#import "CalendarHelpers.h"


enum ChangePeriod {
	kChangePeriodDay,
	kChangePeriodWeek,
	kChangePeriodMonth,
	kChangePeriodYear,
	kNumChangePeriods
};

static NSString* const changePeriodKeys[kNumChangePeriods] = {
	@"obsPreviousDay",
	@"obsPreviousWeek",
	@"obsPreviousMonth",
	@"obsPreviousYear"
};

static NSString* const changePeriodLabels[kNumChangePeriods] = {
	@"PREVIOUS DAY",
	@"LAST WEEK",
	@"LAST MONTH",
	@"LAST YEAR"
};

static enum ChangePeriod currentChangePeriod = kChangePeriodYear;


@interface PlaceDetailViewController ()

@property (nonatomic, retain) Place* place;
@property (nonatomic) BOOL viewIsActive;

- (void)setWaterPositionForView:(UIView*)waterView percentage:(float)percentage;
- (void)updatePlaceDetailsAnimated:(BOOL)animated;
- (void)orientationChanged:(NSNotification *)notification;
- (void)checkAndShowLandscapeChartIfNeeded;

@end


@implementation PlaceDetailViewController


@synthesize place = _place;
@synthesize headerView = _headerView;
@synthesize footerView = _footerView;
@synthesize loadingLabel = _loadingLabel;
@synthesize percentageLabel = _percentageLabel;
@synthesize volumeLabel = _volumeLabel;
@synthesize dateLabel = _dateLabel;
@synthesize changePeriodLabel = _changePeriodLabel;
@synthesize changePercentLabel = _changePercentLabel;
@synthesize changeVolumeLabel = _changeVolumeLabel;
@synthesize contextLabel = _contextLabel;
@synthesize gaugeView = _gaugeView;
@synthesize mainWaterView = _mainWaterView;
@synthesize secondaryWaterView = _secondaryWaterView;
@synthesize chartViewController = _chartViewController;
@synthesize chartTotalCapacityLabel = _chartTotalCapacityLabel;
@synthesize chartTotalCapacityPercentageLabel = _chartTotalCapacityPercentageLabel;
@synthesize favToggleController = _favToggleController;
@synthesize favToggleItem = _favToggleItem;
@synthesize viewIsActive = _viewIsActive;


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_place release];
	[_headerView release];
	[_footerView release];
	[_loadingLabel release];
	[_percentageLabel release];
	[_volumeLabel release];
	[_dateLabel release];
	[_changePeriodLabel release];
	[_changePercentLabel release];
	[_changeVolumeLabel release];
	[_contextLabel release];
	[_gaugeView release];
	[_mainWaterView release];
	[_secondaryWaterView release];
	[_chartViewController release];
	[_chartTotalCapacityLabel release];
	[_chartTotalCapacityPercentageLabel release];
	[_favToggleController release];
	[_favToggleItem release];
    [super dealloc];
}

- (void)viewDidUnload
{
	self.headerView = nil;
	self.footerView = nil;
	self.loadingLabel = nil;
	self.percentageLabel = nil;
	self.volumeLabel = nil;
	self.dateLabel = nil;
	self.changePeriodLabel = nil;
	self.changePercentLabel = nil;
	self.changeVolumeLabel = nil;
	self.contextLabel = nil;
	self.gaugeView = nil;
	self.mainWaterView = nil;
	self.secondaryWaterView = nil;
	self.favToggleController = nil;
	self.favToggleItem = nil;
	self.chartTotalCapacityLabel = nil;
	self.chartTotalCapacityPercentageLabel = nil;
	[super viewDidUnload];
}

- (id)initWithPlace:(Place*)place;
{
	if ((self = [super initWithNibName:@"PlaceDetailView" bundle:nil])) {
		self.place = place;

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectsDidChangeNotification:) name:NSManagedObjectContextObjectsDidChangeNotification object:[_place managedObjectContext]];
		self.title = _place.longName;

		NSManagedObjectContext* context = [_place managedObjectContext];
		if (_place.type == [PlaceType stateInContext:context]) {
			// Create a back button containing shortName.
			UIBarButtonItem* backItem = [[[UIBarButtonItem alloc] initWithTitle:_place.shortName
																		  style:UIBarButtonItemStyleBordered
																		 target:nil
																		 action:nil] autorelease];
			self.navigationItem.backBarButtonItem = backItem;
		}
		self.viewIsActive = NO;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// These are loaded from the nib:
	_favToggleController.place = _place;
	self.navigationItem.rightBarButtonItem = _favToggleItem;
	self.tableView.tableHeaderView = _headerView;
	self.chartViewController.place = _place;
	[self.chartViewController linkGraphToHostedLayer];
	self.chartViewController.chartDelegate = self;
	self.chartTotalCapacityLabel.layer.cornerRadius = 2.0f;
	self.chartTotalCapacityPercentageLabel.layer.cornerRadius = 2.0f;
	[self.chartViewController setYAxisSetTickLocations:[NSSet setWithObject:[NSDecimalNumber numberWithDouble:1.0]]];

	self.tableView.tableFooterView = _footerView;
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(orientationChanged:) 
												 name:UIDeviceOrientationDidChangeNotification 
											   object:nil];
}

- (void)objectsDidChangeNotification:(NSNotification*)notification
{
	NSDictionary* userInfo = [notification userInfo];
	NSSet* refreshed = [userInfo objectForKey:NSRefreshedObjectsKey];
	NSSet* updated = [userInfo objectForKey:NSUpdatedObjectsKey];
	if ([refreshed containsObject:_place] || [updated containsObject:_place]) {
		[self updatePlaceDetailsAnimated:YES];
	}
}

- (void)setWaterPositionForView:(UIView*)waterView percentage:(float)percentage
{
	if (percentage > 100.0f) {
		percentage = 100.0f;
	}
	CGRect gaugeFrame = self.gaugeView.frame;
	CGRect waterFrame = waterView.frame;
	float gaugeHeight = CGRectGetHeight(gaugeFrame);
	float gaugeBottom = CGRectGetMaxY(gaugeFrame);
	// Allow 5 pixels for the wave height
	waterFrame.origin = CGPointMake(waterFrame.origin.x, gaugeBottom - 5.0f - gaugeHeight * percentage * 0.01f);
	waterView.frame = waterFrame;
}

- (void)updatePlaceDetailsAnimated:(BOOL)animated;
{
	assert([NSThread isMainThread]);

	UIColor *bomDarkBlueColour = [[[UIColor alloc] initWithRed:0.0/255.0 green:85.0/255.0 blue:125.0/255.0 alpha:1.0] autorelease];
	UIColor *bomCharcoalColour = [[[UIColor alloc] initWithRed:16.0/255.0 green:29.0/255.0 blue:36.0/255.0 alpha:1.0] autorelease];
	
	self.title = self.place.longName;
	[self.percentageLabel setMeasurementAsPercentage:self.place.obsCurrent.percentageVolume forceSign:NO];
	self.percentageLabel.textColor = self.place.obsCurrent.percentageVolume ? bomCharcoalColour : [UIColor grayColor];
	[self.volumeLabel setMeasurementAsVolume:self.place.obsCurrent.volume forceSign:NO];
	self.volumeLabel.textColor = self.place.obsCurrent.volume ? bomDarkBlueColour : [UIColor grayColor];
	self.dateLabel.text = [[self.place.obsCurrent.observationDate readableDateWithWeekDay] uppercaseString];
	self.changePeriodLabel.text = changePeriodLabels[currentChangePeriod];
	Observation* obsPrevious = [self.place valueForKey:changePeriodKeys[currentChangePeriod]];
	[self.changePercentLabel setMeasurementAsPercentage:obsPrevious.percentageVolumeChange forceSign:YES];
	self.changePercentLabel.textColor = [obsPrevious.percentageVolumeChange changeColour] ?: [UIColor grayColor];
	[self.changeVolumeLabel setMeasurementAsVolume:obsPrevious.volumeChange forceSign:YES];
	self.changeVolumeLabel.textColor = obsPrevious.volumeChange ? bomDarkBlueColour : [UIColor grayColor];
	self.contextLabel.text = @"";	// FIXME

	if (animated) {
		[UIView beginAnimations:@"water" context:nil];
		[UIView setAnimationDuration:1.0f];
	}
	[self setWaterPositionForView:self.mainWaterView percentage:self.place.obsCurrent.percentageVolume.value];
	// If the change text is "-.-%", always show the secondary level as zero.
	float previousPercent = obsPrevious.percentageVolumeChange ? obsPrevious.percentageVolume.value : 0.0f;
	[self setWaterPositionForView:self.secondaryWaterView percentage:previousPercent];
	if (animated) {
		[UIView commitAnimations];
	}
}

- (IBAction)showNextChangePeriod
{
	currentChangePeriod = (currentChangePeriod + 1) % kNumChangePeriods;
	[self updatePlaceDetailsAnimated:YES];
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	[[DataManager manager] clearQueue];
	[[DataManager manager] loadPlace:self.place entire:YES force:NO];
	[[DataManager manager] loadChartForPlace:self.place force:NO];
	[self.chartViewController viewWillAppear:animated];

	[[UIApplication sharedApplication] addObserver:self forKeyPath:@"networkActivityIndicatorVisible" options:NSKeyValueObservingOptionInitial context:nil];
	[self updatePlaceDetailsAnimated:NO];
	[self setWaterPositionForView:self.mainWaterView percentage:0.0f];
	[self setWaterPositionForView:self.secondaryWaterView percentage:0.0f];
	[super viewWillAppear:animated];
	self.viewIsActive = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (object == [UIApplication sharedApplication] && [keyPath isEqual:@"networkActivityIndicatorVisible"]) {
		self.loadingLabel.hidden = ![UIApplication sharedApplication].networkActivityIndicatorVisible;
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.chartViewController viewDidAppear:animated];
	[self updatePlaceDetailsAnimated:animated];
	[self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self.chartViewController viewWillDisappear:animated];
	[[UIApplication sharedApplication] removeObserver:self forKeyPath:@"networkActivityIndicatorVisible"];
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	self.viewIsActive = NO;
	[super viewDidDisappear:animated];
	[self.chartViewController viewDidDisappear:animated];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	if (motion == UIEventSubtypeMotionShake) {
		[[DataManager manager] explicitLoadRequested];
		[[DataManager manager] clearQueue];
		[[DataManager manager] loadPlace:self.place entire:YES force:YES];
		[[DataManager manager] loadChartForPlace:self.place force:YES];
	}
}


#pragma mark Table view methods

// Provide custom section headers
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 22.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *customHeader = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 20.0)] autorelease];
	customHeader.opaque = YES;
	customHeader.backgroundColor = [UIColor whiteColor];
	UIView *headerBorder = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 21.0, 320.0, 1.0)] autorelease];
	headerBorder.backgroundColor = [UIColor colorWithRed:125.0/255.0 green:206.0/255.0 blue:250.0/255.0 alpha:1.0];
	FancyLabel *headerLabel = [[[FancyLabel alloc] initWithFrame:CGRectMake(8.0, 0.0, 312.0, 20.0)] autorelease];
	headerLabel.backgroundColor = [UIColor whiteColor];
	headerLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:105.0/255.0 blue:205.0/255.0 alpha:1.0];
	headerLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11.0];
	headerLabel.shadowColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
	
	NSString* name = [self tableView:tableView titleForHeaderInSection:section];
	NSManagedObjectContext* context = [[DataManager manager] rootContext];
	if (_place == [Place australiaInContext:context] && [name isEqualToString:[PlaceType cityInContext:context].plural]) {
		headerLabel.text = @"CAPITAL CITIES";
	} else {
		headerLabel.text = [name uppercaseString];
	}

	FancyLabel *rankingLabel = [[[FancyLabel alloc] initWithFrame:CGRectMake(172.0, 1.0, 150.0, 20.0)] autorelease];
	rankingLabel.backgroundColor = [UIColor whiteColor];
	rankingLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:105.0/255.0 blue:205.0/255.0 alpha:1.0];
	rankingLabel.font = [UIFont fontWithName:@"Helvetica" size:9.0];
	rankingLabel.shadowColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
	rankingLabel.text = @"(RANKED BY CAPACITY)";
	
	[customHeader addSubview:headerLabel];
	[customHeader addSubview:rankingLabel];
	[customHeader addSubview:headerBorder];
	
	return customHeader;
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController*)makeFetchedResultsController
{
	NSManagedObjectContext* context = [[DataManager manager] rootContext];
	
	// Create the fetch request
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest setEntity:[Place entity]];
	
	NSSet* types = nil;
	if (_place.type == [PlaceType countryInContext:context]) {
		types = [NSSet setWithObjects:
				 [PlaceType stateInContext:context],
				 [PlaceType cityInContext:context],
				 [PlaceType drainagedivisionInContext:context],
				 nil];
	} else if (_place.type == [PlaceType stateInContext:context]
			   || _place.type == [PlaceType drainagedivisionInContext:context]) {
		types = [NSSet setWithObjects:
				 [PlaceType cityInContext:context],
				 [PlaceType waterstorageInContext:context],
				 nil];
	} else if (_place.type == [PlaceType cityInContext:context]) {
		types = [NSSet setWithObjects:[PlaceType waterstorageInContext:context],
				 nil];
	} else if (_place.type == [PlaceType waterstorageInContext:context]) {
		types = [NSSet setWithObjects:nil];
	}
	
	NSPredicate *predicate = nil;
	predicate = [NSPredicate predicateWithFormat:@"type in %@ && %@ in ascendants", types, _place];
	[fetchRequest setPredicate:predicate];

	NSSortDescriptor *majorSort = [[[NSSortDescriptor alloc] initWithKey:@"type.priority" ascending:YES] autorelease];
	NSSortDescriptor *minorSort = [[[NSSortDescriptor alloc] initWithKey:@"obsCurrent.capacity.value" ascending:NO] autorelease];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:majorSort, minorSort, nil]];
	
	// PlaceCell displays obsCurrent
	NSArray* prefetchKeys = [NSArray arrayWithObject:@"obsCurrent"];
	[fetchRequest setRelationshipKeyPathsForPrefetching:prefetchKeys];
	
	return [[[NSFetchedResultsController alloc]
					 initWithFetchRequest:fetchRequest
					 managedObjectContext:context
					 sectionNameKeyPath:@"type.plural"
					 cacheName:nil] autorelease];
}

- (void)landscapeViewControllerDidAppear
{
	// For the case where the user switches to landscape and then back to portrait while
	// the modal view controller is still appearing. It is not possible to dismiss it
	// while it is appearing, so this callback lets us dismiss it when it has finished
	// appearing.
	[self checkAndShowLandscapeChartIfNeeded];
}

- (void)landscapeViewControllerDidDisappear
{
	// For the case where the user switches to portrait and back to landscape while the
	// modal view controller is still disappearing. It is not possible to present a modal
	// view controller while one is still disappearing, so this callback lets us present
	// it when the old one has finished disappearing.
	[self checkAndShowLandscapeChartIfNeeded];
}

- (void)orientationChanged:(NSNotification *)notification
{
	[self checkAndShowLandscapeChartIfNeeded];
}

- (void)checkAndShowLandscapeChartIfNeeded
{
	UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
	if (nil == self.modalViewController
		&& self.viewIsActive
		&& UIDeviceOrientationIsLandscape(orientation))
	{
		LandscapeViewController* landscapeViewController = [[[LandscapeViewController alloc] initWithPlace:self.place] autorelease];
		landscapeViewController.delegate = self;
		[self presentModalViewController:landscapeViewController animated:YES];
	}
	else if (self.modalViewController
			 && orientation == UIDeviceOrientationPortrait)
	{
		[self dismissModalViewControllerAnimated:YES];
	}
}


#pragma mark ChartDelegate protocol

- (void)chartUpdated
{
	/*
	 CGRect percentageFrame = self.chartTotalCapacityPercentageLabel.frame;
	 NSLog(@"percFrame=(%f,%f) (%f,%f)", percentageFrame.origin.x, percentageFrame.origin.y, percentageFrame.size.width, percentageFrame.size.height);
	 NSDecimal plotPoint[2];
	 plotPoint[CPCoordinateX] = [[NSDecimalNumber numberWithFloat:1.0f] decimalValue];
	 plotPoint[CPCoordinateY] = [[NSDecimalNumber numberWithFloat:0.0f] decimalValue];
	 CGPoint coord = [self.chartViewController viewCoordinatesForChartPoint:plotPoint];
	 percentageFrame.origin.y = self.chartViewController.view.frame.origin.y + coord.y;
	 NSLog(@"coord=%f,%f", coord.x, coord.y);
	 //self.chartTotalCapacityPercentageLabel.frame = percentageFrame;
	 NSLog(@"percFrame=(%f,%f) (%f,%f)", 
	 self.chartTotalCapacityPercentageLabel.frame.origin.x, 
	 self.chartTotalCapacityPercentageLabel.frame.origin.y, 
	 self.chartTotalCapacityPercentageLabel.frame.size.width, 
	 self.chartTotalCapacityPercentageLabel.frame.size.height);
	 */
	Measurement* m = [[[Measurement alloc] init] autorelease];
	m.value = [_place.chart.yMax doubleValue];
	m.unit = _place.obsCurrent.capacity.unit;
	if (_place.chart.yMax && fabs(_place.obsCurrent.capacity.value - [_place.chart.yMax doubleValue]) > 1.0)
	{
		NSLog(@"Warning: Total capacity volume from observation (%f) is different from yMax value from chart (%f) Label in chart will be incorrect",
			  _place.obsCurrent.capacity.value,
			  [_place.chart.yMax doubleValue]);
	}
	[self.chartTotalCapacityLabel setMeasurementAsVolume:self.place.obsCurrent.capacity forceSign:NO];
	CGRect totalFrame = self.chartTotalCapacityLabel.frame;
	CGSize expectedLabelSize = [_chartTotalCapacityLabel.text
								sizeWithFont:_chartTotalCapacityLabel.font
								forWidth:200.0f
								lineBreakMode:_chartTotalCapacityLabel.lineBreakMode];
	totalFrame.size.width = expectedLabelSize.width + 18;
	totalFrame.origin.x = _headerView.frame.size.width - totalFrame.size.width + 1;
	self.chartTotalCapacityLabel.frame = totalFrame;
}

@end
