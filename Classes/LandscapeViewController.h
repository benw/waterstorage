//
//  LandscapeViewController.h
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

#import <UIKit/UIKit.h>
#import "ChartViewController.h"

@class LandscapeViewController;
@class Place;
@class ChartViewController;


@protocol LandscapeViewControllerDelegate <NSObject>

- (void)landscapeViewControllerDidAppear;

@end


@interface LandscapeViewController : UIViewController <ChartDelegate, MarkerLabelDelegate>
{
	id <LandscapeViewControllerDelegate> _delegate;
	UINavigationItem* _titleNavigationItem;
	Place* _place;
	ChartViewController* _chartViewController;
	UIView* _valuesOverlay;
	BOOL _valuesOverlayIsVisible;
	UILabel* _chartTotalCapacityLabel;
	UILabel* _chartTotalCapacityPercentageLabel;

}

@property (nonatomic, assign) id <LandscapeViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UINavigationItem* titleNavigationItem;
@property (nonatomic, retain) IBOutlet ChartViewController* chartViewController;
@property (nonatomic, retain) IBOutlet UIView* valuesOverlay;
@property (nonatomic, retain) IBOutlet UILabel* chartTotalCapacityLabel;
@property (nonatomic, retain) IBOutlet UILabel* chartTotalCapacityPercentageLabel;

- (id)initWithPlace:(Place*)place;

@end
