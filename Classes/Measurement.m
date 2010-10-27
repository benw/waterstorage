//
//  Measurement.m
//  Slake
//
//  Created by Ben Williamson on 25/05/10.
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

#import "Measurement.h"


@implementation Measurement

@synthesize value;
@synthesize unit;

- (void)dealloc
{
	[unit release];
	[super dealloc];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if ((self = [super init])) {
		self.value = [decoder decodeDoubleForKey:@"value"];
		self.unit = [decoder decodeObjectForKey:@"unit"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeDouble:self.value forKey:@"value"];
	[encoder encodeObject:self.unit forKey:@"unit"];
}

// Returns the measurement formatted as a percentage.
- (NSString*) textAsPercentageForceSign:(BOOL)forceSign
{
	static NSNumberFormatter* formatter = nil;
	if (formatter == nil) {
		formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[formatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en"] autorelease]];
		[formatter setMaximumFractionDigits:1];
		[formatter setMinimumFractionDigits:1];
	}

	double x = self.value;
	if (x > -0.05 && x <= 0.0) {
		// Eliminate "-0.0%"
		x = +0.0;
	}
	formatter.positivePrefix = forceSign ? @"+" : @"";
	NSString* number = [formatter stringFromNumber:[NSNumber numberWithDouble:x]];
	return [NSString stringWithFormat:@"%@%@", number, self.unit];
}

// Returns the measurement formatted as a volume.
- (NSString*) textAsVolumeForceSign:(BOOL)forceSign
{
	static NSNumberFormatter* formatter = nil;
	if (formatter == nil) {
		formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[formatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en"] autorelease]];
		[formatter setMaximumFractionDigits:0];
	}
	formatter.positivePrefix = forceSign ? @"+" : @"";
	NSString* number = [formatter stringFromNumber:[NSNumber numberWithDouble:self.value]];
	return [NSString stringWithFormat:@"%@ %@", number, self.unit];
}

- (UIColor*) changeColour
{
	if (self.value < -0.001) {
		return [UIColor colorWithRed:0.8f green:0.0f blue:0.0f alpha:1.0f];
	} else if (self.value > 0.001) {
		return [UIColor colorWithRed:0.0f green:0.65f blue:0.0f alpha:1.0f];
	} else {
		return [UIColor blackColor];
	}
}

@end


@implementation UILabel (Measurement)

- (void)setMeasurementAsPercentage:(Measurement*)measurement forceSign:(BOOL)forceSign
{
	if (measurement) {
		NSString* number = [measurement textAsPercentageForceSign:forceSign];
		self.text = number;
		self.accessibilityLabel = number;
	} else {
		self.text = @"--.-%";
		self.accessibilityLabel = @"no percentage";
	}
}

- (void)setMeasurementAsVolume:(Measurement*)measurement forceSign:(BOOL)forceSign
{
	if (measurement) {
		NSString* number = [measurement textAsVolumeForceSign:forceSign];
		self.text = number;
		self.accessibilityLabel = [number stringByReplacingOccurrencesOfString:@"ML" 
																	withString:@"megalitres"];
	} else {
		self.text = @"--- ML";
		self.accessibilityLabel = @"no volume";
	}
}

@end

