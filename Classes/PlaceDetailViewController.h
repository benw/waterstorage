//
//  PlaceDetailViewController.h
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

#import <UIKit/UIKit.h>

#import "FetchedPlaceTableViewController.h"
#import "LandscapeViewController.h"


@class FavouriteToggleButtonController;
@class Place;
@class ChartViewController;


@interface PlaceDetailViewController : FetchedPlaceTableViewController <ChartDelegate, LandscapeViewControllerDelegate>
{
	UIView* _headerView;
	UIView* _footerView;
	UILabel* _loadingLabel;
	UILabel* _percentageLabel;
	UILabel* _volumeLabel;
	UILabel* _dateLabel;
	UILabel* _changePeriodLabel;
	UILabel* _changePercentLabel;
	UILabel* _changeVolumeLabel;
	UILabel* _contextLabel;
	UIView* _gaugeView;
	UIView* _mainWaterView;
	UIView* _secondaryWaterView;
	ChartViewController* _chartViewController;
	UILabel* _chartTotalCapacityLabel;
	UILabel* _chartTotalCapacityPercentageLabel;
	FavouriteToggleButtonController* _favToggleController;
	UIBarButtonItem* _favToggleItem;
	BOOL _viewIsActive;

	Place* _place;
}

@property (nonatomic, retain) IBOutlet UIView* headerView;
@property (nonatomic, retain) IBOutlet UIView* footerView;
@property (nonatomic, retain) IBOutlet UILabel* loadingLabel;
@property (nonatomic, retain) IBOutlet UILabel* percentageLabel;
@property (nonatomic, retain) IBOutlet UILabel* volumeLabel;
@property (nonatomic, retain) IBOutlet UILabel* dateLabel;
@property (nonatomic, retain) IBOutlet UILabel* changePeriodLabel;
@property (nonatomic, retain) IBOutlet UILabel* changePercentLabel;
@property (nonatomic, retain) IBOutlet UILabel* changeVolumeLabel;
@property (nonatomic, retain) IBOutlet UILabel* contextLabel;
@property (nonatomic, retain) IBOutlet UIView* gaugeView;
@property (nonatomic, retain) IBOutlet UIView* mainWaterView;
@property (nonatomic, retain) IBOutlet UIView* secondaryWaterView;
@property (nonatomic, retain) IBOutlet ChartViewController* chartViewController;
@property (nonatomic, retain) IBOutlet UILabel* chartTotalCapacityLabel;
@property (nonatomic, retain) IBOutlet UILabel* chartTotalCapacityPercentageLabel;
@property (nonatomic, retain) IBOutlet FavouriteToggleButtonController* favToggleController;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* favToggleItem;

- (id)initWithPlace:(Place*)place;

// Cycle through previous day / week / month / year
- (IBAction)showNextChangePeriod;

@end
