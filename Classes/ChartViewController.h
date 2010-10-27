//
//  ChartViewController.h
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

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@class Place;
@class Chart;
@class ChartValue;
@class Measurement;

@protocol MarkerLabelDelegate

- (void)showLabelsCurrentYearDate:(NSDate*)date
		   currentYearPercentage:(Measurement*)currentYearPercentage
			   currentYearVolume:(Measurement*)currentYearVolume
					lastYearDate:(NSDate*)date
			  lastYearPercentage:(Measurement*)lastYearPercentage
				  lastYearVolume:(Measurement*)lastYearVolume
						awayFrom:(float)viewXPosition;

- (void)hideLabels;

@end

//notify chart values changes for any rendering
@protocol ChartDelegate

- (void)chartUpdated;

@end


@interface ChartViewController : UIViewController <CPPlotSpaceDelegate, CPPlotDataSource>
{
	CPXYGraph* graph;
	Place* place;
	Chart* _chart;	// not retained
	//marker
	CPScatterPlot* _markerPlot;
	id <MarkerLabelDelegate> _markerLabelDelegate;
	id <ChartDelegate> _chartDelegate;
	int _xCoordinate;
	float _viewXPosition;
	NSNumber* _currentYearYCoordinate;
	NSNumber* _lastYearYCoordinate;
}

@property (nonatomic, retain) Place* place;
@property (nonatomic, assign) id <MarkerLabelDelegate> markerLabelDelegate;
@property (nonatomic, assign) id <ChartDelegate> chartDelegate;

// To be called once the nib containing the chart controller and its view has been loaded.
// Typically when the superview did load.
- (void)linkGraphToHostedLayer;

// To be called on parent's view controller viewDidLoad
-(void)setXAxisSetTickLocations:(NSSet*)locations;
-(void)setYAxisSetTickLocations:(NSSet*)locations;
-(void)setXAxisRangeFrom:(float)start length:(float)length;

-(CGPoint)viewCoordinatesForChartPoint:(NSDecimal*)chartPoint;

@end
