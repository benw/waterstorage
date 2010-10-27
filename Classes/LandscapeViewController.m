//
//  LandscapeViewController.m
//  Slake
//
//  Created by Ben Williamson on 22/06/10.
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

#import "LandscapeViewController.h"
#import "DataManager.h"
#import "ChartViewController.h"
#import "Place.h"
#import "Chart.h"
#import "Observation.h"
#import "Measurement.h"
#import "CalendarHelpers.h"


@interface LandscapeViewController ()

@property (nonatomic, retain) Place* place;
@property (nonatomic) BOOL valuesOverlayIsVisible;

@end


@implementation LandscapeViewController

@synthesize delegate = _delegate;
@synthesize titleNavigationItem = _titleNavigationItem;
@synthesize place = _place;
@synthesize chartViewController = _chartViewController;
@synthesize valuesOverlay = _valuesOverlay;
@synthesize valuesOverlayIsVisible = _valuesOverlayIsVisible;
@synthesize currentYearDate = _currentYearDate;
@synthesize currentYearPercentage = _currentYearPercentage;
@synthesize currentYearVolume = _currentYearVolume;
@synthesize lastYearDate = _lastYearDate;
@synthesize lastYearPercentage = _lastYearPercentage;
@synthesize lastYearVolume = _lastYearVolume;
@synthesize chartTotalCapacityLabel = _chartTotalCapacityLabel;
@synthesize chartTotalCapacityPercentageLabel = _chartTotalCapacityPercentageLabel;


- (void)dealloc
{
	[_titleNavigationItem release];
	[_place release];
	[_chartViewController release];
	[_valuesOverlay release];
	[_currentYearDate release];
	[_currentYearPercentage release];
	[_currentYearVolume release];
	[_lastYearDate release];
	[_lastYearPercentage release];
	[_lastYearVolume release];
	[_chartTotalCapacityLabel release];
	[_chartTotalCapacityPercentageLabel release];
    [super dealloc];
}

- (void)viewDidUnload
{
	self.titleNavigationItem = nil;
	self.valuesOverlay = nil;
	self.currentYearDate = nil;
	self.currentYearPercentage = nil;
	self.currentYearVolume = nil;
	self.lastYearDate = nil;
	self.lastYearPercentage = nil;
	self.lastYearVolume = nil;
	self.chartTotalCapacityLabel = nil;
	self.chartTotalCapacityPercentageLabel = nil;
	[super viewDidUnload];
}

- (id)initWithPlace:(Place*)place;
{
	if ((self = [super initWithNibName:@"LandscapeView" bundle:nil])) {
		self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		self.place = place;
		self.valuesOverlayIsVisible = NO;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.titleNavigationItem.title = self.place.longName;
	self.chartViewController.place = self.place;
	[self.chartViewController linkGraphToHostedLayer];
	//add 3 pixels on each side to help touching side values with finger
	[self.chartViewController setXAxisRangeFrom:-2.0f length:372.0f];
	[self.chartViewController setYAxisSetTickLocations:[NSSet setWithObjects:
	  [NSDecimalNumber numberWithDouble:0.25],
	  [NSDecimalNumber numberWithDouble:0.5],
	  [NSDecimalNumber numberWithDouble:0.75],
	  [NSDecimalNumber numberWithDouble:1.0],
	  nil]];
	
	[self.chartViewController setYAxisSetTickLocations:[NSSet setWithObjects:
														[NSDecimalNumber numberWithDouble:0.1],
														[NSDecimalNumber numberWithDouble:0.2],
														[NSDecimalNumber numberWithDouble:0.3],
														[NSDecimalNumber numberWithDouble:0.4],
														[NSDecimalNumber numberWithDouble:0.5],
														[NSDecimalNumber numberWithDouble:0.6],
														[NSDecimalNumber numberWithDouble:0.7],
														[NSDecimalNumber numberWithDouble:0.8],
														[NSDecimalNumber numberWithDouble:0.9],
														[NSDecimalNumber numberWithDouble:1.0],
														nil]];
	
	[self.chartViewController setXAxisSetTickLocations:[NSSet setWithObjects:
	  [NSDecimalNumber numberWithInt:0 + 1], 
	  [NSDecimalNumber numberWithInt:31 + 1], 
	  [NSDecimalNumber numberWithInt:59 + 1], 
	  [NSDecimalNumber numberWithInt:90 + 1], 
	  [NSDecimalNumber numberWithInt:120 + 1], 
	  [NSDecimalNumber numberWithInt:151 + 1], 
	  [NSDecimalNumber numberWithInt:181 + 1], 
	  [NSDecimalNumber numberWithInt:212 + 1], 
	  [NSDecimalNumber numberWithInt:243 + 1], 
	  [NSDecimalNumber numberWithInt:273 + 1], 
	  [NSDecimalNumber numberWithInt:304 + 1], 
	  [NSDecimalNumber numberWithInt:334 + 1], 
	  [NSDecimalNumber numberWithInt:365 + 1], 
	  nil]];
	
	self.valuesOverlay.alpha = 0.0f;
	self.valuesOverlay.layer.cornerRadius = 3.0f;
	[self.valuesOverlay viewWithTag:1].layer.cornerRadius = 3.0f;
	self.chartViewController.chartDelegate = self;
	self.chartTotalCapacityLabel.layer.cornerRadius = 2.0f;
	self.chartTotalCapacityPercentageLabel.layer.cornerRadius = 2.0f;
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.chartViewController viewWillAppear:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.chartViewController viewDidAppear:animated];
	[self.chartViewController setMarkerLabelDelegate:self];
	[self.delegate landscapeViewControllerDidAppear];
	//for shake to reload
	[self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self.chartViewController setMarkerLabelDelegate:nil];
	[self.chartViewController viewWillDisappear:animated];
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self.chartViewController viewDidDisappear:animated];
	[self.delegate landscapeViewControllerDidDisappear];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


#pragma mark ChartDelegate protocol

- (void)chartUpdated
{
	[self.chartTotalCapacityLabel setMeasurementAsVolume:self.place.obsCurrent.capacity forceSign:NO];
	CGRect totalFrame = self.chartTotalCapacityLabel.frame;
	CGSize expectedLabelSize = [_chartTotalCapacityLabel.text
								sizeWithFont:_chartTotalCapacityLabel.font
								forWidth:200.0f
								lineBreakMode:_chartTotalCapacityLabel.lineBreakMode];
	totalFrame.size.width = expectedLabelSize.width + 18;
	totalFrame.origin.x = self.view.bounds.size.width - totalFrame.size.width + 1;
	self.chartTotalCapacityLabel.frame = totalFrame;
}


#pragma mark MarkerLabelDelegate protocol

-(void)showLabelsCurrentYearDate:(NSDate*)currentYearDate
		   currentYearPercentage:(Measurement*)currentYearPercentage
			   currentYearVolume:(Measurement*)currentYearVolume
					lastYearDate:(NSDate*)lastYearDate
			  lastYearPercentage:(Measurement*)lastYearPercentage
				  lastYearVolume:(Measurement*)lastYearVolume
						awayFrom:(float)viewXPosition
{
	self.currentYearDate.text = [[currentYearDate readableDateNoWeekDay] uppercaseString];
	[self.currentYearPercentage setMeasurementAsPercentage:currentYearPercentage forceSign:NO];
	[self.currentYearVolume setMeasurementAsVolume:currentYearVolume forceSign:NO];
	self.lastYearDate.text = [[lastYearDate readableDateNoWeekDay] uppercaseString];
	[self.lastYearPercentage setMeasurementAsPercentage:lastYearPercentage forceSign:NO];
	[self.lastYearVolume setMeasurementAsVolume:lastYearVolume forceSign:NO];
	CGRect frame = self.valuesOverlay.frame;
	float margin = 20.0f;
	float leftLimit = frame.size.width + margin;
	float rightLimit = self.view.bounds.size.width - self.valuesOverlay.frame.size.width - margin;
	if (_valuesOverlayIsVisible && (viewXPosition < leftLimit || 
								   viewXPosition > rightLimit))
	{
		[UIView beginAnimations:@"moveOverlay" context:nil];
		[UIView setAnimationDuration:0.2f];
	}
	if (viewXPosition < leftLimit)
	{
		frame.origin.x = self.view.frame.size.height - self.valuesOverlay.frame.size.width;
		self.valuesOverlay.frame = frame;
	}
	else if (viewXPosition > rightLimit)
	{
		frame.origin.x = 0.0f;
		self.valuesOverlay.frame = frame;
	}
	if (_valuesOverlayIsVisible && (viewXPosition < leftLimit || viewXPosition > rightLimit))
	{
		[UIView commitAnimations];
	}
	self.valuesOverlay.alpha = 1.0f;
	self.valuesOverlayIsVisible = YES;
	
	if (UIAccessibilityIsVoiceOverRunning != nil && UIAccessibilityIsVoiceOverRunning()) {
		NSMutableString* message = [NSMutableString stringWithCapacity:50];
		[message appendString:self.currentYearDate.text];
		[message appendString:@" "];
		[message appendString:self.currentYearPercentage.accessibilityLabel];
		[message appendString:@" "];
		[message appendString:self.currentYearVolume.accessibilityLabel];
		[message appendString:@" "];
		[message appendString:self.lastYearDate.text];
		[message appendString:@" "];
		[message appendString:self.lastYearPercentage.accessibilityLabel];
		[message appendString:@" "];
		[message appendString:self.lastYearVolume.accessibilityLabel];
		UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message); 
	}
}

-(void)hideLabels
{
	self.valuesOverlay.alpha = 0.0f;
	self.valuesOverlayIsVisible = NO;
}

#pragma mark shake to reload

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	if (motion == UIEventSubtypeMotionShake) {
		[[DataManager manager] explicitLoadRequested];
		[[DataManager manager] clearQueue];
		if (self.place) {
			//load chart first
			[[DataManager manager] loadChartForPlace:self.place force:YES];
			[[DataManager manager] loadPlace:self.place entire:YES force:YES];
		}
	}
}

@end
