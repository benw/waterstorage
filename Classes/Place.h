//
//  Place.h
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

#import <CoreData/CoreData.h>

@class PlaceType;
@class Chart;
@class Observation;

// This notification is posted when a place is created
// that has not been seen before. The notification's object
// is the place's URN, an NSString.
extern NSString* kNewPlaceNotification;

@interface Place : NSManagedObject
{
}

// The <identifier> URN of the region/feature.
@property (nonatomic, retain) NSString* urn;

// AU for Australia, VIC for Victoria etc,
// same as longName for cities / drainage divisions / storages.
@property (nonatomic, retain) NSString* shortName;

// The place name we normally present to the user.
@property (nonatomic, retain) NSString* longName;

// The latitude and longitude of the map label
@property (nonatomic, retain) NSNumber* latitude;
@property (nonatomic, retain) NSNumber* longitude;

// The date on which the <region> or <feature> element
// describing this place was last encountered.
@property (nonatomic, retain) NSDate* loadDate;

// The date on which the complete file describing this
// place (named according to its URN) was last completely loaded.
// We use this to ensure that we know about all children places.
@property (nonatomic, retain) NSDate* completeLoadDate;

// The place type - country, state, city, drainage division or storage.
@property (nonatomic, retain) PlaceType* type;

// The ascendant places with which this place is associated.
@property (nonatomic, retain) NSSet* ascendants;
@property (nonatomic, retain) NSSet* children;

// The current chart for this place.
@property (nonatomic, retain) Chart* chart;

// Current and previous observations.
@property (nonatomic, retain) Observation* obsCurrent;
@property (nonatomic, retain) Observation* obsPreviousDay;
@property (nonatomic, retain) Observation* obsPreviousWeek;
@property (nonatomic, retain) Observation* obsPreviousMonth;
@property (nonatomic, retain) Observation* obsPreviousYear;

/**
 If a place with this urn already exists, it is returned.
 If not, one is created and inserted into the context.
 */
+ (Place*)placeWithUrn:(NSString*)urn context:(NSManagedObjectContext*)context;

+ (Place*)australiaInContext:(NSManagedObjectContext*)context;

+ (NSEntityDescription*)entity;

@end


@interface Place (GeneratedAccessors)

- (void)addChildrenObject:(Place*)child;

@end
