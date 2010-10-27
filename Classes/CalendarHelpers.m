//
//  CalendarHelpers.m
//  Slake
//
//  Created by Quentin Leseney on 7/07/10.
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
#import "CalendarHelpers.h"

@implementation NSCalendar (CalendarHelpers)

+ (BOOL)isLeapYear:(int)year
{
	if (year % 400 == 0) {
		return YES;
	} else if (year % 100 == 0) {
		return NO;
	} else if (year % 4 == 0) {
		return YES;
	} else {
		return NO;
	}
}

+ (NSCalendar*)gregorian
{
	static NSCalendar* gregorian = nil;
	if (gregorian == nil) {
		gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		gregorian.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en"] autorelease];
		gregorian.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	}
	return gregorian;
}

@end


@implementation NSDate (CalendarHelpers)

- (NSString*)readableDateWithWeekDay
{
	static NSDateFormatter* dateFormatterReadableDateWithWeekDay = nil;
	if (dateFormatterReadableDateWithWeekDay == nil) {
		dateFormatterReadableDateWithWeekDay = [[NSDateFormatter alloc] init];
		dateFormatterReadableDateWithWeekDay.dateFormat = @"EEE d MMM yyyy";
		dateFormatterReadableDateWithWeekDay.calendar = [NSCalendar gregorian];
		dateFormatterReadableDateWithWeekDay.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en"] autorelease];
		dateFormatterReadableDateWithWeekDay.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	}
	return [dateFormatterReadableDateWithWeekDay stringFromDate:self];
}

- (NSString*)readableDateNoWeekDay
{
	static NSDateFormatter* dateFormatterReadableDateNoWeekDay = nil;
	if (dateFormatterReadableDateNoWeekDay == nil) {
		dateFormatterReadableDateNoWeekDay = [[NSDateFormatter alloc] init];
		dateFormatterReadableDateNoWeekDay.dateFormat = @"d MMM yyyy";
		dateFormatterReadableDateNoWeekDay.calendar = [NSCalendar gregorian];
		dateFormatterReadableDateNoWeekDay.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en"] autorelease];
		dateFormatterReadableDateNoWeekDay.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	}
	return [dateFormatterReadableDateNoWeekDay stringFromDate:self];
}

@end


@implementation NSDateFormatter (CalendarHelpers)

// Date formatter to parse NSString representing a basic (no hyphen) calendar date of the form 20100330
// http://en.wikipedia.org/wiki/ISO_8601#Calendar_dates
+ (NSDateFormatter*) dateFormatterWithFormat:(NSString*)format
{
	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	dateFormatter.calendar = [NSCalendar gregorian];
	dateFormatter.dateFormat = format;
	dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	return dateFormatter;
}

@end


@implementation NSObject (CalendarHelpers)

// Parse an NSString representing an extended (using separators) date and time of the form 2010-03-30T00:00:00
// http://en.wikipedia.org/wiki/ISO_8601#Combined_date_and_time_representations
- (NSDate*) dateFromStringISO8601DateTimeExtended
{
	static NSDateFormatter* dateFormatterISO8601DateTimeExtended = nil;
	if (dateFormatterISO8601DateTimeExtended == nil) {
		dateFormatterISO8601DateTimeExtended = [[NSDateFormatter alloc] init];
		dateFormatterISO8601DateTimeExtended.calendar = [NSCalendar gregorian];
		dateFormatterISO8601DateTimeExtended.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
		dateFormatterISO8601DateTimeExtended.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	}
	
	if ([self isKindOfClass:[NSString class]]) {
		return [dateFormatterISO8601DateTimeExtended dateFromString:(NSString*)self];
	} else {
		return nil;
	}
}

@end
