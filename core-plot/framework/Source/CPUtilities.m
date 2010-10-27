
#import "CPUtilities.h"

#pragma mark -
#pragma mark Decimal Numbers

/**
 *	@brief Converts an NSDecimal value to a NSInteger.
 *	@param decimalNumber The NSDecimal value.
 *	@return The converted value.
 **/
NSInteger CPDecimalIntegerValue(NSDecimal decimalNumber)
{
	return (NSInteger)[[NSDecimalNumber decimalNumberWithDecimal:decimalNumber] intValue]; 
}

/**
 *	@brief Converts an NSDecimal value to a float.
 *	@param decimalNumber The NSDecimal value.
 *	@return The converted value.
 **/
float CPDecimalFloatValue(NSDecimal decimalNumber)
{
	return (float)[[NSDecimalNumber decimalNumberWithDecimal:decimalNumber] doubleValue]; 
}

/**
 *	@brief Converts an NSDecimal value to a double.
 *	@param decimalNumber The NSDecimal value.
 *	@return The converted value.
 **/
double CPDecimalDoubleValue(NSDecimal decimalNumber)
{
	return (double)[[NSDecimalNumber decimalNumberWithDecimal:decimalNumber] doubleValue]; 
}

/**
 *	@brief Converts a NSInteger value to an NSDecimal.
 *	@param i The NSInteger value.
 *	@return The converted value.
 **/
NSDecimal CPDecimalFromInteger(NSInteger i)
{
	return [[NSNumber numberWithInteger:i] decimalValue]; 
}

/**
 *	@brief Converts a NSUInteger value to an NSDecimal.
 *	@param i The NSUInteger value.
 *	@return The converted value.
 **/
NSDecimal CPDecimalFromUnsignedInteger(NSUInteger i)
{
	return [[NSNumber numberWithUnsignedInteger:i] decimalValue]; 
}

/**
 *	@brief Converts a float value to an NSDecimal.
 *	@param f The float value.
 *	@return The converted value.
 **/
NSDecimal CPDecimalFromFloat(float f)
{
	return [[NSNumber numberWithFloat:f] decimalValue]; 
}

/**
 *	@brief Converts a double value to an NSDecimal.
 *	@param d The double value.
 *	@return The converted value.
 **/
NSDecimal CPDecimalFromDouble(double d)
{
	return [[NSNumber numberWithDouble:d] decimalValue]; 
}

/**
 *	@brief Adds two NSDecimals together.
 *	@param leftOperand The left-hand side of the addition operation.
 *	@param rightOperand The right-hand side of the addition operation.
 *	@return The result of the addition.
 **/
NSDecimal CPDecimalAdd(NSDecimal leftOperand, NSDecimal rightOperand)
{
	NSDecimal result;
	NSDecimalAdd(&result, &leftOperand, &rightOperand, NSRoundBankers);
	return result;
}

/**
 *	@brief Subtracts one NSDecimal from another.
 *	@param leftOperand The left-hand side of the subtraction operation.
 *	@param rightOperand The right-hand side of the subtraction operation.
 *	@return The result of the subtraction.
 **/
NSDecimal CPDecimalSubtract(NSDecimal leftOperand, NSDecimal rightOperand)
{
	NSDecimal result;
	NSDecimalSubtract(&result, &leftOperand, &rightOperand, NSRoundBankers);
	return result;
}

/**
 *	@brief Multiplies two NSDecimals together.
 *	@param leftOperand The left-hand side of the multiplication operation.
 *	@param rightOperand The right-hand side of the multiplication operation.
 *	@return The result of the multiplication.
 **/
NSDecimal CPDecimalMultiply(NSDecimal leftOperand, NSDecimal rightOperand)
{
	NSDecimal result;
	NSDecimalMultiply(&result, &leftOperand, &rightOperand, NSRoundBankers);
	return result;
}

/**
 *	@brief Divides one NSDecimal by another.
 *	@param numerator The numerator of the multiplication operation.
 *	@param denominator The denominator of the multiplication operation.
 *	@return The result of the division.
 **/
NSDecimal CPDecimalDivide(NSDecimal numerator, NSDecimal denominator)
{
	NSDecimal result;
	NSDecimalDivide(&result, &numerator, &denominator, NSRoundBankers);
	return result;
}

/**
 *	@brief Checks to see if one NSDecimal is greater than another.
 *	@param leftOperand The left side of the comparison.
 *	@param rightOperand The right side of the comparison.
 *	@return YES if the left operand is greater than the right, NO otherwise.
 **/
BOOL CPDecimalGreaterThan(NSDecimal leftOperand, NSDecimal rightOperand)
{
	return (NSDecimalCompare(&leftOperand, &rightOperand) == NSOrderedDescending);
}

/**
 *	@brief Checks to see if one NSDecimal is greater than or equal to another.
 *	@param leftOperand The left side of the comparison.
 *	@param rightOperand The right side of the comparison.
 *	@return YES if the left operand is greater than or equal to the right, NO otherwise.
 **/
BOOL CPDecimalGreaterThanOrEqualTo(NSDecimal leftOperand, NSDecimal rightOperand)
{
	return (NSDecimalCompare(&leftOperand, &rightOperand) != NSOrderedAscending);
}

/**
 *	@brief Checks to see if one NSDecimal is less than another.
 *	@param leftOperand The left side of the comparison.
 *	@param rightOperand The right side of the comparison.
 *	@return YES if the left operand is less than the right, NO otherwise.
 **/
BOOL CPDecimalLessThan(NSDecimal leftOperand, NSDecimal rightOperand)
{
	return (NSDecimalCompare(&leftOperand, &rightOperand) == NSOrderedAscending);
}

/**
 *	@brief Checks to see if one NSDecimal is less than or equal to another.
 *	@param leftOperand The left side of the comparison.
 *	@param rightOperand The right side of the comparison.
 *	@return YES if the left operand is less than or equal to the right, NO otherwise.
 **/
BOOL CPDecimalLessThanOrEqualTo(NSDecimal leftOperand, NSDecimal rightOperand)
{
	return (NSDecimalCompare(&leftOperand, &rightOperand) != NSOrderedDescending);
}

/**
 *	@brief Checks to see if one NSDecimal is equal to another.
 *	@param leftOperand The left side of the comparison.
 *	@param rightOperand The right side of the comparison.
 *	@return YES if the left operand is equal to the right, NO otherwise.
 **/
BOOL CPDecimalEquals(NSDecimal leftOperand, NSDecimal rightOperand)
{
	return (NSDecimalCompare(&leftOperand, &rightOperand) == NSOrderedSame);	
}

/**
 *	@brief Parses a string and extracts the numeric value as an NSDecimal.
 *	@param stringRepresentation The string value.
 *	@return The numeric value extracted from the string.
 **/
NSDecimal CPDecimalFromString(NSString *stringRepresentation)
{
	// The following NSDecimalNumber-based creation of NSDecimals from strings is slower than 
	// the NSScanner-based method: (307000 operations per second vs. 582000 operations per second for NSScanner)
	
/*	NSDecimalNumber *newNumber = [[NSDecimalNumber alloc] initWithString:@"1.0" locale:[NSLocale currentLocale]];
	newDecimal = [newNumber decimalValue];
	[newNumber release];*/
	
	NSDecimal result;
	NSScanner *theScanner = [[NSScanner alloc] initWithString:stringRepresentation];
	[theScanner scanDecimal:&result];
	[theScanner release];
	
	return result;
}

/**
 *	@brief Creates and returns an NSDecimal struct that represents the value "not a number".
 *
 *	Calling <code>NSDecimalIsNotANumber()</code> on this value will return <code>YES</code>.
 *
 *	@return An NSDecimal struct that represents the value "not a number".
 **/
NSDecimal CPDecimalNaN(void)
{
	NSDecimal decimalNaN = [[NSDecimalNumber zero] decimalValue];
	decimalNaN._length = 0;
	decimalNaN._isNegative = YES;
	
	return decimalNaN;
}

#pragma mark -
#pragma mark Ranges

/**
 *	@brief Expands an NSRange by the given amount.
 *
 *	The <code>location</code> of the resulting NSRange will be non-negative.
 *
 *	@param range The NSRange to expand.
 *	@param expandBy The amount the expand the range by.
 *	@return The expanded range.
 **/
NSRange CPExpandedRange(NSRange range, NSInteger expandBy) 
{
    NSInteger loc = MAX(0, (int)range.location - expandBy);
    NSInteger lowerExpansion = range.location - loc;
    NSInteger length = range.length + lowerExpansion + expandBy;
    return NSMakeRange(loc, length);
}

#pragma mark -
#pragma mark Colors

/**
 *	@brief Extracts the color information from a CGColorRef and returns it as a CPRGBAColor.
 *
 *	Supports RGBA and grayscale colorspaces.
 *
 *	@param color The color.
 *	@return The RGBA components of the color.
 **/
CPRGBAColor CPRGBAColorFromCGColor(CGColorRef color)
{
	CPRGBAColor rgbColor;
	
	size_t numComponents = CGColorGetNumberOfComponents(color);
	
	if (numComponents == 2) {
		const CGFloat *components = CGColorGetComponents(color);
		CGFloat all = components[0];
		rgbColor.red = all;
		rgbColor.green = all;
		rgbColor.blue = all;
		rgbColor.alpha = components[1];
	} else {
		const CGFloat *components = CGColorGetComponents(color);
		rgbColor.red = components[0];
		rgbColor.green = components[1];
		rgbColor.blue = components[2];
		rgbColor.alpha = components[3];
	}

	return rgbColor;
}

#pragma mark -
#pragma mark Coordinates

/**
 *	@brief Determines the CPCoordinate that is orthogonal to the one provided.
 *
 *	The current implementation is two-dimensional--X is orthogonal to Y and Y is orthogonal to X.
 *
 *	@param coord The CPCoordinate.
 *	@return The orthogonal CPCoordinate.
 **/
CPCoordinate CPOrthogonalCoordinate(CPCoordinate coord)
{
	return ( coord == CPCoordinateX ? CPCoordinateY : CPCoordinateX );
}

#pragma mark -
#pragma mark Quartz pixel-alignment functions

/**
 *	@brief Aligns a point in user space to integral coordinates in device space.
 *
 *	Ensures that the x and y coordinates are at a pixel corner in device space.
 *	Drawn from <i>Programming with Quartz</i> by D. Gelphman, B. Laden.
 *
 *	@param context The graphics context.
 *	@param p The point in user space.
 *	@return The device aligned point in user space.
 **/
CGPoint CPAlignPointToUserSpace(CGContextRef context, CGPoint p)
{
    // Compute the coordinates of the point in device space.
    p = CGContextConvertPointToDeviceSpace(context, p);
    
    // Ensure that coordinates are at exactly the corner
    // of a device pixel.
    p.x = round(p.x) + 0.5f;
    p.y = round(p.y) + 0.5f;
    
    // Convert the device aligned coordinate back to user space.
    return CGContextConvertPointToUserSpace(context, p);
}

/**
 *	@brief Adjusts a size in user space to integral dimensions in device space.
 *
 *	Ensures that the width and height are an integer number of device pixels.
 *	Drawn from <i>Programming with Quartz</i> by D. Gelphman, B. Laden.
 *
 *	@param context The graphics context.
 *	@param s The size in user space.
 *	@return The device aligned size in user space.
 **/
CGSize CPAlignSizeToUserSpace(CGContextRef context, CGSize s)
{
    // Compute the size in device space.
    s = CGContextConvertSizeToDeviceSpace(context, s);
    
    // Ensure that size is an integer multiple of device pixels.
    s.width = round(s.width);
    s.height = round(s.height);
    
    // Convert back to user space.
    return CGContextConvertSizeToUserSpace(context, s);
}

/**
 *	@brief Aligns a rectangle in user space to integral coordinates in device space.
 *
 *	Ensures that the x and y coordinates are at a pixel corner in device space
 *	and the width and height are an integer number of device pixels.
 *	Drawn from <i>Programming with Quartz</i> by D. Gelphman, B. Laden.
 *
 *	@note This function produces a width and height
 *	that is less than or equal to the original width.
 *	@param context The graphics context.
 *	@param r The rectangle in user space.
 *	@return The device aligned rectangle in user space.
 **/
CGRect CPAlignRectToUserSpace(CGContextRef context, CGRect r)
{
    // Compute the coordinates of the rectangle in device space.
    r = CGContextConvertRectToDeviceSpace(context, r);
    
    // Ensure that the x and y coordinates are at a pixel corner.
    r.origin.x = round(r.origin.x) + 0.5f;
    r.origin.y = round(r.origin.y) + 0.5f;
    
    // Ensure that the width and height are an integer number of
    // device pixels. We now use ceil to make something at least as large as the original
    r.size.width = round(r.size.width);
    r.size.height = round(r.size.height);
    
    // Convert back to user space.
    return CGContextConvertRectToUserSpace(context, r);
}

#pragma mark -
#pragma mark String formatting for Core Graphics structs

/**	@brief Creates a string representation of the given point.
 *	@param p The point.
 *	@return A string with the format <code>{x, y}</code>.
 **/
NSString *CPStringFromPoint(CGPoint p)
{
	return [NSString stringWithFormat:@"{%g, %g}", p.x, p.y];
}

/**	@brief Creates a string representation of the given point.
 *	@param s The size.
 *	@return A string with the format <code>{width, height}</code>.
 **/
NSString *CPStringFromSize(CGSize s)
{
	return [NSString stringWithFormat:@"{%g, %g}", s.width, s.height];
}

/**	@brief Creates a string representation of the given point.
 *	@param r The rectangle.
 *	@return A string with the format <code>{{x, y}, {width, height}}</code>.
 **/
NSString *CPStringFromRect(CGRect r)
{
	return [NSString stringWithFormat:@"{{%g, %g}, {%g, %g}}", r.origin.x, r.origin.y, r.size.width, r.size.height];
}
