
#import <Foundation/Foundation.h>
#import "CPDefinitions.h"

/// @file

/// @name NSDecimal Utilities
/// @{
NSInteger CPDecimalIntegerValue(NSDecimal decimalNumber);
float   CPDecimalFloatValue(NSDecimal decimalNumber);
double  CPDecimalDoubleValue(NSDecimal decimalNumber);

NSDecimal CPDecimalFromInteger(NSInteger i);
NSDecimal CPDecimalFromUnsignedInteger(NSUInteger i);
NSDecimal CPDecimalFromFloat(float f);
NSDecimal CPDecimalFromDouble(double d);

NSDecimal CPDecimalAdd(NSDecimal leftOperand, NSDecimal rightOperand);
NSDecimal CPDecimalSubtract(NSDecimal leftOperand, NSDecimal rightOperand);
NSDecimal CPDecimalMultiply(NSDecimal leftOperand, NSDecimal rightOperand);
NSDecimal CPDecimalDivide(NSDecimal numerator, NSDecimal denominator);

BOOL CPDecimalGreaterThan(NSDecimal leftOperand, NSDecimal rightOperand);
BOOL CPDecimalGreaterThanOrEqualTo(NSDecimal leftOperand, NSDecimal rightOperand);
BOOL CPDecimalLessThan(NSDecimal leftOperand, NSDecimal rightOperand);
BOOL CPDecimalLessThanOrEqualTo(NSDecimal leftOperand, NSDecimal rightOperand);
BOOL CPDecimalEquals(NSDecimal leftOperand, NSDecimal rightOperand);

NSDecimal CPDecimalFromString(NSString *stringRepresentation);

NSDecimal CPDecimalNaN(void);
/// @}

/// @name Ranges
/// @{
NSRange CPExpandedRange(NSRange range, NSInteger expandBy);
/// @}

/// @name Coordinates
/// @{
CPCoordinate CPOrthogonalCoordinate(CPCoordinate coord);
/// @}

/// @name Gradient colors
/// @{
CPRGBAColor CPRGBAColorFromCGColor(CGColorRef color);
/// @}

/// @name Quartz Pixel-Alignment Functions
/// @{
CGPoint CPAlignPointToUserSpace(CGContextRef context, CGPoint p);
CGSize CPAlignSizeToUserSpace(CGContextRef context, CGSize s);
CGRect CPAlignRectToUserSpace(CGContextRef context, CGRect r);
/// @}

/// @name String formatting for Core Graphics structs
/// @{
NSString *CPStringFromPoint(CGPoint p);
NSString *CPStringFromSize(CGSize s);
NSString *CPStringFromRect(CGRect r);
/// @}
