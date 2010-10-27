
#import <Foundation/Foundation.h>
#import "CPDefinitions.h"

@class CPAxis;
@class CPLayer;
@class CPTextStyle;

@interface CPAxisLabel : NSObject {
	@private
	CPAxis *axis;
    CPLayer *contentLayer;
    CGFloat offset;
    CGFloat rotation;
    NSDecimal tickLocation;
}

@property (nonatomic, readwrite, retain) CPAxis *axis;
@property (nonatomic, readwrite, retain) CPLayer *contentLayer;
@property (nonatomic, readwrite, assign) CGFloat offset;
@property (nonatomic, readwrite, assign) CGFloat rotation;
@property (nonatomic, readwrite) NSDecimal tickLocation;

/// @name Initialization
/// @{
-(id)initWithText:(NSString *)newText textStyle:(CPTextStyle *)style;
-(id)initWithContentLayer:(CPLayer *)layer;
///	@}

/// @name Layout
/// @{
-(void)positionRelativeToViewPoint:(CGPoint)point forCoordinate:(CPCoordinate)coordinate inDirection:(CPSign)direction;
-(void)positionBetweenViewPoint:(CGPoint)firstPoint andViewPoint:(CGPoint)secondPoint forCoordinate:(CPCoordinate)coordinate inDirection:(CPSign)direction;
///	@}

@end
