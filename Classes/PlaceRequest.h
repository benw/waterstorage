//
//  PlaceRequest.h
//  Slake
//
//  Created by Ben Williamson on 31/05/10.
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

#import <Foundation/Foundation.h>
#import "DataRequest.h"

@class Place;

@interface PlaceRequest : DataRequest
{
	Place* place;
	BOOL isEntireLoad;
}

@property (nonatomic, retain) Place* place;
@property (nonatomic) BOOL isEntireLoad;

// The entire flag specifies what must be up to date in order for the request to be satisfied:
// YES requires the place's details and all its children to have current observations;
// NO just requires current observations for the place itself, which is often satisfied
// incidentally by loading an ascendant place.
//
// The force flag specifies what "recent enough" means:
// YES means loaded since the request was created.
// NO means loaded within the last x hours, defined by [DataManager dateIsRecentEnough:].
+ (PlaceRequest*)placeRequestForPlace:(Place*)place entire:(BOOL)entire force:(BOOL)force;

@end
