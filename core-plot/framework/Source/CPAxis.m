#import "CPAxis.h"
#import "CPAxisLabel.h"
#import "CPAxisLabelGroup.h"
#import "CPAxisSet.h"
#import "CPAxisTitle.h"
#import "CPGridLines.h"
#import "CPLineStyle.h"
#import "CPPlotRange.h"
#import "CPPlotSpace.h"
#import "CPPlotArea.h"
#import "CPTextLayer.h"
#import "CPTextStyle.h"
#import "CPUtilities.h"
#import "CPPlatformSpecificCategories.h"
#import "CPUtilities.h"
#import "NSDecimalNumberExtensions.h"

///	@cond
@interface CPAxis ()

@property (nonatomic, readwrite, assign) BOOL needsRelabel;
@property (nonatomic, readwrite, assign) __weak CPGridLines *minorGridLines;
@property (nonatomic, readwrite, assign) __weak CPGridLines *majorGridLines;
@property (nonatomic, readwrite, assign) BOOL labelFormatterChanged;

-(void)tickLocationsBeginningAt:(NSDecimal)beginNumber increasing:(BOOL)increasing majorTickLocations:(NSSet **)newMajorLocations minorTickLocations:(NSSet **)newMinorLocations;
-(NSDecimal)nextLocationFromCoordinateValue:(NSDecimal)coord increasing:(BOOL)increasing interval:(NSDecimal)interval;
-(NSSet *)filteredTickLocations:(NSSet *)allLocations;
-(void)updateAxisLabelsAtLocations:(NSSet *)locations;

@end
///	@endcond

#pragma mark -

/**	@brief An abstract axis class.
 **/
@implementation CPAxis

// Axis

/**	@property axisLineStyle
 *  @brief The line style for the axis line.
 *	If nil, the line is not drawn.
 **/
@synthesize axisLineStyle;

/**	@property coordinate
 *	@brief The axis coordinate.
 **/
@synthesize coordinate;

/**	@property labelingOrigin
 *	@brief The origin used for axis labels.
 *  The default value is 0. It is only used when the axis labeling
 *  policy is CPAxisLabelingPolicyFixedInterval. The origin is
 *  a reference point used to being labeling. Labels are added
 *	at the origin, as well as at fixed intervals above and below
 *  the origin.
 **/
@synthesize labelingOrigin;

/**	@property tickDirection
 *	@brief The tick direction.
 *  The direction is given as the sign that ticks extend along
 *  the axis (eg positive, or negative).
 **/
@synthesize tickDirection;

/**	@property visibleRange
 *	@brief The plot range over which the axis and ticks are visible.
 *  Use this to restrict an axis to less than the full plot area width.
 *  Set to nil for no restriction.
 **/
@synthesize visibleRange;

/**	@property gridLinesRange
 *	@brief The plot range over which the grid lines are visible.
 *  Note that this range applies to the orthogonal coordinate, not
 *  the axis coordinate itself.
 *  Set to nil for no restriction.
 **/
@synthesize gridLinesRange;


// Title

/**	@property titleTextStyle
 *  @brief The text style used to draw the axis title text.
 **/
@synthesize titleTextStyle;

/**	@property axisTitle
 *  @brief The axis title.
 *	If nil, no title is drawn.
 **/
@synthesize axisTitle;

/**	@property titleOffset
 *	@brief The offset distance between the axis title and the axis line.
 **/
@synthesize titleOffset;

/**	@property title
 *	@brief A convenience property for setting the text title of the axis.
 **/
@synthesize title;

/**	@property titleLocation
 *	@brief The position along the axis where the axis title should be centered.
 *  If NaN, the <code>defaultTitleLocation</code> will be used.
 **/
@dynamic titleLocation;

/**	@property defaultTitleLocation
 *	@brief The position along the axis where the axis title should be centered
 *  if <code>titleLocation</code> is NaN.
 **/
@dynamic defaultTitleLocation;

// Plot space

/**	@property plotSpace
 *	@brief The plot space for the axis.
 **/
@synthesize plotSpace;

// Labels

/**	@property labelingPolicy
 *	@brief The axis labeling policy.
 **/
@synthesize labelingPolicy;

/**	@property labelOffset
 *	@brief The offset distance between the tick marks and labels.
 **/
@synthesize labelOffset;

/**	@property labelRotation
 *	@brief The rotation of the axis labels in radians.
 *  Set this property to M_PI/2.0 to have labels read up the screen, for example.
 **/
@synthesize labelRotation;

/**	@property labelTextStyle
 *	@brief The text style used to draw the label text.
 **/
@synthesize labelTextStyle;

/**	@property labelFormatter
 *	@brief The number formatter used to format the label text.
 *  If you need a non-numerical label, such as a date, you can use a formatter than turns
 *  the numerical plot coordinate into a string (eg 'Jan 10, 2010'). 
 *  The CPTimeFormatter is useful for this purpose.
 **/
@synthesize labelFormatter;

@synthesize labelFormatterChanged;

/**	@property axisLabels
 *	@brief The set of axis labels.
 **/
@synthesize axisLabels;

/**	@property needsRelabel
 *	@brief If YES, the axis needs to be relabeled before the layer content is drawn.
 **/
@synthesize needsRelabel;

/**	@property labelExclusionRanges
 *	@brief An array of CPPlotRange objects. Any tick marks and labels falling inside any of the ranges in the array will not be drawn.
 **/
@synthesize labelExclusionRanges;

/**	@property delegate
 *	@brief The axis delegate.
 **/
@synthesize delegate;

// Major ticks

/**	@property majorIntervalLength
 *	@brief The distance between major tick marks expressed in data coordinates.
 **/
@synthesize majorIntervalLength;

/**	@property majorTickLineStyle
 *  @brief The line style for the major tick marks.
 *	If nil, the major ticks are not drawn.
 **/
@synthesize majorTickLineStyle;

/**	@property majorTickLength
 *	@brief The length of the major tick marks.
 **/
@synthesize majorTickLength;

/**	@property majorTickLocations
 *	@brief A set of axis coordinates for all major tick marks.
 **/
@synthesize majorTickLocations;

/**	@property preferredNumberOfMajorTicks
 *	@brief The number of ticks that should be targeted when autogenerating positions.
 *  This property only applies when the CPAxisLabelingPolicyAutomatic policy is in use.
 **/
@synthesize preferredNumberOfMajorTicks;

// Minor ticks

/**	@property minorTicksPerInterval
 *	@brief The number of minor tick marks drawn in each major tick interval.
 **/
@synthesize minorTicksPerInterval;

/**	@property minorTickLineStyle
 *  @brief The line style for the minor tick marks.
 *	If nil, the minor ticks are not drawn.
 **/
@synthesize minorTickLineStyle;

/**	@property minorTickLength
 *	@brief The length of the minor tick marks.
 **/
@synthesize minorTickLength;

/**	@property minorTickLocations
 *	@brief A set of axis coordinates for all minor tick marks.
 **/
@synthesize minorTickLocations;

// Grid Lines

/**	@property majorGridLineStyle
 *  @brief The line style for the major grid lines.
 *	If nil, the major grid lines are not drawn.
 **/
@synthesize majorGridLineStyle;

/**	@property minorGridLineStyle
 *  @brief The line style for the minor grid lines.
 *	If nil, the minor grid lines are not drawn.
 **/
@synthesize minorGridLineStyle;

// Layers

/**	@property separateLayers
 *  @brief Use separate layers for drawing grid lines?
 *
 *	If NO, the default, the major and minor grid lines are drawn in layers shared with other axes.
 *	If YES, the grid lines are drawn in their own layers.
 **/
@synthesize separateLayers;

/**	@property plotArea
 *  @brief The plot area that the axis belongs to.
 **/
@synthesize plotArea;

/**	@property minorGridLines
 *  @brief The layer that draws the minor grid lines.
 **/
@synthesize minorGridLines;

/**	@property majorGridLines
 *  @brief The layer that draws the major grid lines.
 **/
@synthesize majorGridLines;

/**	@property axisSet
 *  @brief The axis set that the axis belongs to.
 **/
@dynamic axisSet;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		plotSpace = nil;
		majorTickLocations = [[NSSet set] retain];
		minorTickLocations = [[NSSet set] retain];
        preferredNumberOfMajorTicks = 5;
		minorTickLength = 3.0;
		majorTickLength = 5.0;
		labelOffset = 2.0;
        labelRotation = 0.0;
		title = nil;
		titleOffset = 30.0;
		axisLineStyle = [[CPLineStyle alloc] init];
		majorTickLineStyle = [[CPLineStyle alloc] init];
		minorTickLineStyle = [[CPLineStyle alloc] init];
		majorGridLineStyle = nil;
		minorGridLineStyle = nil;
		labelingOrigin = [[NSDecimalNumber zero] decimalValue];
		majorIntervalLength = [[NSDecimalNumber one] decimalValue];
		minorTicksPerInterval = 1;
		coordinate = CPCoordinateX;
		labelingPolicy = CPAxisLabelingPolicyFixedInterval;
		labelTextStyle = [[CPTextStyle alloc] init];
		NSNumberFormatter *newFormatter = [[NSNumberFormatter alloc] init];
		newFormatter.minimumIntegerDigits = 1;
		newFormatter.maximumFractionDigits = 1; 
        newFormatter.minimumFractionDigits = 1;
        labelFormatter = newFormatter;
		labelFormatterChanged = YES;
		axisLabels = [[NSSet set] retain];
        tickDirection = CPSignNone;
		axisTitle = nil;
		titleTextStyle = [[CPTextStyle alloc] init];
		titleLocation = CPDecimalNaN();
        needsRelabel = YES;
		labelExclusionRanges = nil;
		delegate = nil;
		plotArea = nil;
		separateLayers = NO;
		minorGridLines = nil;
		majorGridLines = nil;
		
		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(void)dealloc
{
	[plotSpace release];	
	[majorTickLocations release];
	[minorTickLocations release];
	[title release];
	[axisLineStyle release];
	[majorTickLineStyle release];
	[minorTickLineStyle release];
    [majorGridLineStyle release];
    [minorGridLineStyle release];
	[labelFormatter release];
	[axisLabels release];
	[labelTextStyle release];
	[titleTextStyle release];
	[labelExclusionRanges release];
    [visibleRange release];
    [gridLinesRange release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Ticks

-(NSDecimal)nextLocationFromCoordinateValue:(NSDecimal)coord increasing:(BOOL)increasing interval:(NSDecimal)interval
{
	if ( increasing ) {
		return CPDecimalAdd(coord, interval);
	} else {
		return CPDecimalSubtract(coord, interval);
	}
}

-(void)tickLocationsBeginningAt:(NSDecimal)beginNumber increasing:(BOOL)increasing majorTickLocations:(NSSet **)newMajorLocations minorTickLocations:(NSSet **)newMinorLocations
{
	NSMutableSet *majorLocations = [NSMutableSet set];
	NSMutableSet *minorLocations = [NSMutableSet set];
	NSDecimal majorInterval = self.majorIntervalLength;
	NSDecimal coord = beginNumber;
	CPPlotRange *range = [[self.plotSpace plotRangeForCoordinate:self.coordinate] copy];
    if ( self.visibleRange ) {
        [range intersectionPlotRange:self.visibleRange];
    }
	
	if ( CPDecimalGreaterThan(majorInterval, CPDecimalFromInteger(0)) ) {
		while ( range &&
			   ((increasing && CPDecimalLessThanOrEqualTo(coord, range.end)) || 
				(!increasing && CPDecimalGreaterThanOrEqualTo(coord, range.location))) ) {
				   
			// Major tick
			if ( CPDecimalLessThanOrEqualTo(coord, range.end) && CPDecimalGreaterThanOrEqualTo(coord, range.location) ) {
				[majorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:coord]];
			}

			// Minor ticks
			if ( self.minorTicksPerInterval > 0 ) {
				NSDecimal minorInterval = CPDecimalDivide(majorInterval, CPDecimalFromUnsignedInteger(self.minorTicksPerInterval+1));
				NSDecimal minorCoord = [self nextLocationFromCoordinateValue:coord increasing:increasing interval:minorInterval];
			   
				for ( NSUInteger minorTickIndex = 0; minorTickIndex < self.minorTicksPerInterval; minorTickIndex++) {
					if ( CPDecimalLessThanOrEqualTo(minorCoord, range.end) && CPDecimalGreaterThanOrEqualTo(minorCoord, range.location)) {
						[minorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:minorCoord]];
					}
					minorCoord = [self nextLocationFromCoordinateValue:minorCoord increasing:increasing interval:minorInterval];
				}
			}
			   
			coord = [self nextLocationFromCoordinateValue:coord increasing:increasing interval:majorInterval];
		}
	}
	else {
		if ( CPDecimalLessThanOrEqualTo(coord, range.end) && CPDecimalGreaterThanOrEqualTo(coord, range.location) ) {
			[majorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:coord]];
		}		
	}
	
	[range release];
	*newMajorLocations = majorLocations;
	*newMinorLocations = minorLocations;
}


-(void)autoGenerateMajorTickLocations:(NSSet **)newMajorLocations minorTickLocations:(NSSet **)newMinorLocations 
{
    // cache some values ;
    CPPlotRange *range = [self.plotSpace plotRangeForCoordinate:self.coordinate];
    NSUInteger numTicks = self.preferredNumberOfMajorTicks;
    NSUInteger minorTicks = self.minorTicksPerInterval ; 
    double length = range.lengthDouble ;   
    
    // Create sets for locations
    NSMutableSet *majorLocations = [NSMutableSet set];
    NSMutableSet *minorLocations = [NSMutableSet set];
    
    // Filter troublesome values and return empty sets
    if ( length == 0 || numTicks == 0 ) {
       	*newMajorLocations = majorLocations;
        *newMinorLocations = minorLocations;
        return;
    }
    
    // Determine interval value
    double roughInterval = length/numTicks ;
	double exponentValue = pow( 10.0, floor(log10(fabs(roughInterval))) ) ;    
    double interval = exponentValue * trunc(roughInterval/exponentValue) ;
    
    // Determinie minor interval
    double minorInterval = interval / (minorTicks + 1) ;
        
    // Calculate actual range location and end considering the visible range
    CPPlotRange *theVisibleRange = self.visibleRange ;
    double location = range.locationDouble ;
    double end = location + length ;
    if ( theVisibleRange ) {
	    double visibleLocation = theVisibleRange.locationDouble ;
    	double visibleLength = theVisibleRange.lengthDouble ;
    	location = (location > visibleLocation ? location : visibleLocation ) ;
        end = (end < visibleLocation+visibleLength ? end : visibleLocation+visibleLength ) ;
    }
    
    // Determine the initial and final major indexes for the actual visible range
    NSInteger initialIndex = floor(location/interval) ;  // can be negative
    NSInteger finalIndex = ceil(end/interval) ;  // can be negative
    
    // Iterate through the indexes with visible ticks and build the locations sets
    NSInteger i ;
    for ( i = initialIndex ; i <= finalIndex ; i++ ) {
    	double pointLocation = i * interval ;
        NSUInteger j ;
        for ( j = 0 ; j < minorTicks ; j++ ) {
        	double minorPointLocation = pointLocation + minorInterval * (j+1) ;
            if ( minorPointLocation < location ) continue ;
            if ( minorPointLocation > end ) continue ;
            [minorLocations addObject:[NSDecimalNumber numberWithDouble:minorPointLocation]] ;
        }
        
        if ( pointLocation < location ) continue ;
        if ( pointLocation > end ) continue ;
        [majorLocations addObject:[NSDecimalNumber numberWithDouble:pointLocation]] ;
    }
    
    // Return tick locations sets
    *newMajorLocations = majorLocations;
    *newMinorLocations = minorLocations;
}

/*
-(void)autoGenerateMajorTickLocationsOld:(NSSet **)newMajorLocations minorTickLocations:(NSSet **)newMinorLocations 
{
    NSMutableSet *majorLocations = [NSMutableSet setWithCapacity:self.preferredNumberOfMajorTicks];
    NSMutableSet *minorLocations = [NSMutableSet setWithCapacity:(self.preferredNumberOfMajorTicks + 1) * self.minorTicksPerInterval];
    
    if ( self.preferredNumberOfMajorTicks == 0 ) {
    	*newMajorLocations = majorLocations;
        *newMinorLocations = minorLocations;
        return;
    }
    
    // Determine starting interval
    CPPlotRange *range = [self.plotSpace plotRangeForCoordinate:self.coordinate];
    NSUInteger numTicks = self.preferredNumberOfMajorTicks;
    NSUInteger numIntervals = MAX( 1, (NSInteger)numTicks - 1 );
    NSDecimalNumber *rangeLength = [NSDecimalNumber decimalNumberWithDecimal:range.length];
    NSDecimalNumber *interval = [rangeLength decimalNumberByDividingBy:
    	(NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:numIntervals]];
    
    // Determine round number using the NSString with scientific format of numbers
    NSString *intervalString = [NSString stringWithFormat:@"%e", [interval doubleValue]];
    NSScanner *numberScanner = [NSScanner scannerWithString:intervalString];
	NSInteger firstDigit;
    [numberScanner scanInteger:&firstDigit];
    
    // Ignore decimal part of scientific number
    [numberScanner scanUpToString:@"e" intoString:nil];
    [numberScanner scanString:@"e" intoString:nil];
    
    // Scan the exponent
    NSInteger exponent;
    [numberScanner scanInteger:&exponent];
    
    // Set interval which has been rounded. Make sure it is not zero.
    interval = [NSDecimalNumber decimalNumberWithMantissa:MAX(1,firstDigit) exponent:exponent isNegative:NO];
    
    // Determine how many points there should be now
    NSDecimalNumber *numPointsDecimal = [rangeLength decimalNumberByDividingBy:interval];
    NSInteger numPoints = [numPointsDecimal integerValue];
    
    // Find first location
    NSDecimalNumber *rangeLocation = [NSDecimalNumber decimalNumberWithDecimal:range.location];
    NSInteger firstPointMultiple = [[rangeLocation decimalNumberByDividingBy:interval] integerValue];
    NSDecimalNumber *pointLocation = [interval decimalNumberByMultiplyingBy:(NSDecimalNumber *)[NSDecimalNumber numberWithInteger:firstPointMultiple]];
    if ( firstPointMultiple >= 0 && ![rangeLocation isEqualToNumber:pointLocation] ) {
        firstPointMultiple++;
        pointLocation = [interval decimalNumberByMultiplyingBy:(NSDecimalNumber *)[NSDecimalNumber numberWithInteger:firstPointMultiple]];
    }    
	
	// If the intervals divide exactly, and the first point is at the beginning of the range,
	// you can end up with one extra tick
	if ( [rangeLocation isEqualToNumber:pointLocation] ) numPoints++;
	
    // Determine all locations
    NSInteger majorIndex;
    NSDecimalNumber *minorInterval = nil;
    if ( self.minorTicksPerInterval > 0 ) {
		minorInterval = [interval decimalNumberByDividingBy:(NSDecimalNumber *)[NSDecimalNumber numberWithInteger:self.minorTicksPerInterval+1]];
	}
    for ( majorIndex = 0; majorIndex < numPoints; majorIndex++ ) {
    	// Major ticks
        if ( !self.visibleRange || [self.visibleRange contains:pointLocation.decimalValue] ) 
        	[majorLocations addObject:pointLocation];
        
        // Minor ticks
        if ( minorInterval && majorIndex < numPoints - 1) {
            NSDecimalNumber *minorLocation = [pointLocation decimalNumberByAdding:minorInterval];
            for ( NSUInteger minorIndex = 0; minorIndex < self.minorTicksPerInterval; minorIndex++ ) {
                if ( !self.visibleRange || [self.visibleRange contains:minorLocation.decimalValue] ) 
                    [minorLocations addObject:minorLocation];
                minorLocation = [minorLocation decimalNumberByAdding:minorInterval];
            }
        }
        // Prepare for next major tick
        pointLocation = [pointLocation decimalNumberByAdding:interval];
    }
    
    *newMajorLocations = majorLocations;
    *newMinorLocations = minorLocations;
}
*/

#pragma mark -
#pragma mark Labels

/**	@brief Updates the set of axis labels using the given locations.
 *	Existing axis label objects and content layers are reused where possible.
 *	@param locations A set of NSDecimalNumber label locations.
 **/
-(void)updateAxisLabelsAtLocations:(NSSet *)locations
{
	if ( [self.delegate respondsToSelector:@selector(axis:shouldUpdateAxisLabelsAtLocations:)] ) {
		BOOL shouldContinue = [self.delegate axis:self shouldUpdateAxisLabelsAtLocations:locations];
		if ( !shouldContinue ) return;
	}

	if ( locations.count == 0 ) {
		self.axisLabels = nil;
		return;
	}
	
	CGFloat offset = self.labelOffset;
	switch ( self.tickDirection ) {
		case CPSignNone:
			offset += self.majorTickLength / 2.0;
			break;
		case CPSignPositive:
		case CPSignNegative:
			offset += self.majorTickLength;
			break;
	}
	
	
	[self.plotArea setAxisSetLayersForType:CPGraphLayerTypeAxisLabels];

    NSMutableSet *newAxisLabels = [[NSMutableSet alloc] initWithCapacity:locations.count];
	CPAxisLabel *blankLabel = [[CPAxisLabel alloc] initWithText:nil textStyle:nil];
	CPAxisLabelGroup *axisLabelGroup = self.plotArea.axisLabelGroup;
	CALayer *lastLayer = nil;

	for ( NSDecimalNumber *tickLocation in locations ) {
		CPAxisLabel *newAxisLabel;
		BOOL needsNewContentLayer = NO;
		
		// reuse axis labels where possible--will prevent flicker when updating layers
		blankLabel.tickLocation = [tickLocation decimalValue];
		CPAxisLabel *oldAxisLabel = [self.axisLabels member:blankLabel];
		
		if ( oldAxisLabel ) {
			newAxisLabel = [oldAxisLabel retain];
		}
		else {
			newAxisLabel = [[CPAxisLabel alloc] initWithText:nil textStyle:nil];
			newAxisLabel.tickLocation = [tickLocation decimalValue];
			needsNewContentLayer = YES;
		}
		
		newAxisLabel.rotation = self.labelRotation;
		newAxisLabel.offset = offset;
		
		if ( needsNewContentLayer || self.labelFormatterChanged ) {
			NSString *labelString = [self.labelFormatter stringForObjectValue:tickLocation];
			CPTextLayer *newLabelLayer = [[CPTextLayer alloc] initWithText:labelString style:self.labelTextStyle];
			[oldAxisLabel.contentLayer removeFromSuperlayer];
			newAxisLabel.contentLayer = newLabelLayer;
			
			if ( lastLayer ) {
				[axisLabelGroup insertSublayer:newLabelLayer below:lastLayer];
			}
			else {
				[axisLabelGroup insertSublayer:newLabelLayer atIndex:[self.plotArea sublayerIndexForAxis:self layerType:CPGraphLayerTypeAxisLabels]];
			}
			
			[newLabelLayer release];
			CGPoint tickBasePoint = [self viewPointForCoordinateDecimalNumber:newAxisLabel.tickLocation];
			[newAxisLabel positionRelativeToViewPoint:tickBasePoint forCoordinate:CPOrthogonalCoordinate(self.coordinate) inDirection:self.tickDirection];
		}

		lastLayer = newAxisLabel.contentLayer;
		
		[newAxisLabels addObject:newAxisLabel];
		[newAxisLabel release];
	}
	[blankLabel release];
	
	// remove old labels that are not needed any more from the layer hierarchy
	NSMutableSet *oldAxisLabels = [self.axisLabels mutableCopy];
	[oldAxisLabels minusSet:newAxisLabels];
	for ( CPAxisLabel *label in oldAxisLabels ) {
		[label.contentLayer removeFromSuperlayer];
	}
	[oldAxisLabels release];
	
	// do not use accessor because we've already updated the layer hierarchy
	[axisLabels release];
	axisLabels = newAxisLabels;
	[self setNeedsLayout];		
	self.labelFormatterChanged = NO;
}

/**	@brief Marks the receiver as needing to update the labels before the content is next drawn.
 **/
-(void)setNeedsRelabel
{
    self.needsRelabel = YES;
}

/**	@brief Updates the axis labels.
 **/
-(void)relabel
{
    if ( !self.needsRelabel ) return;
	if ( !self.plotSpace ) return;
	if ( self.delegate && ![self.delegate axisShouldRelabel:self] ) {
        self.needsRelabel = NO;
        return;
    }

	NSMutableSet *allNewMajorLocations = [NSMutableSet set];
	NSMutableSet *allNewMinorLocations = [NSMutableSet set];
	NSSet *newMajorLocations, *newMinorLocations;
	
	switch ( self.labelingPolicy ) {
		case CPAxisLabelingPolicyNone:
        case CPAxisLabelingPolicyLocationsProvided:
            // Locations are set by user
			break;
		case CPAxisLabelingPolicyFixedInterval:
			// Add ticks in negative direction
			[self tickLocationsBeginningAt:self.labelingOrigin increasing:NO majorTickLocations:&newMajorLocations minorTickLocations:&newMinorLocations];
			[allNewMajorLocations unionSet:newMajorLocations];  
			[allNewMinorLocations unionSet:newMinorLocations];  
			
			// Add ticks in positive direction
			[self tickLocationsBeginningAt:self.labelingOrigin increasing:YES majorTickLocations:&newMajorLocations minorTickLocations:&newMinorLocations];
			[allNewMajorLocations unionSet:newMajorLocations];
			[allNewMinorLocations unionSet:newMinorLocations];
			
			break;
        case CPAxisLabelingPolicyAutomatic:
			[self autoGenerateMajorTickLocations:&newMajorLocations minorTickLocations:&newMinorLocations];
            allNewMajorLocations = (NSMutableSet *)newMajorLocations;
			allNewMinorLocations = (NSMutableSet *)newMinorLocations;
			break;
		case CPAxisLabelingPolicyLogarithmic:
			// TODO: logarithmic labeling policy
			break;
	}
	
	switch ( self.labelingPolicy ) {
		case CPAxisLabelingPolicyNone:
        case CPAxisLabelingPolicyLocationsProvided:
            // Locations are set by user--no filtering required
			break;
		default:
			// Filter and set tick locations	
			self.majorTickLocations = [self filteredMajorTickLocations:allNewMajorLocations];
			self.minorTickLocations = [self filteredMinorTickLocations:allNewMinorLocations];
	}
	
    if ( self.labelingPolicy != CPAxisLabelingPolicyNone ) {
        // Label ticks
		[self updateAxisLabelsAtLocations:self.majorTickLocations];
    }

    self.needsRelabel = NO;
	
	[self.delegate axisDidRelabel:self];
}

-(NSSet *)filteredTickLocations:(NSSet *)allLocations 
{
	NSMutableSet *filteredLocations = [allLocations mutableCopy];
	for ( CPPlotRange *range in self.labelExclusionRanges ) {
		for ( NSDecimalNumber *location in allLocations ) {
			if ( [range contains:[location decimalValue]] ) {
				[filteredLocations removeObject:location];	
			}
		}
	}
	return [filteredLocations autorelease];
}

/**	@brief Removes any major ticks falling inside the label exclusion ranges from the set of tick locations.
 *	@param allLocations A set of major tick locations.
 *	@return The filtered set.
 **/
-(NSSet *)filteredMajorTickLocations:(NSSet *)allLocations
{
	return [self filteredTickLocations:allLocations];
}

/**	@brief Removes any minor ticks falling inside the label exclusion ranges from the set of tick locations.
 *	@param allLocations A set of minor tick locations.
 *	@return The filtered set.
 **/
-(NSSet *)filteredMinorTickLocations:(NSSet *)allLocations
{
	return [self filteredTickLocations:allLocations];
}

#pragma mark -
#pragma mark Titles

-(NSDecimal)defaultTitleLocation
{
	return CPDecimalNaN();
}

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionAxis;
}

-(void)layoutSublayers
{
    for ( CPAxisLabel *label in self.axisLabels ) {
        CGPoint tickBasePoint = [self viewPointForCoordinateDecimalNumber:label.tickLocation];
        [label positionRelativeToViewPoint:tickBasePoint forCoordinate:CPOrthogonalCoordinate(self.coordinate) inDirection:self.tickDirection];
    }

	[self.axisTitle positionRelativeToViewPoint:[self viewPointForCoordinateDecimalNumber:self.titleLocation] forCoordinate:CPOrthogonalCoordinate(self.coordinate) inDirection:self.tickDirection];
}

#pragma mark -
#pragma mark Accessors

-(void)setAxisLabels:(NSSet *)newLabels 
{
    if ( newLabels != axisLabels ) {
        for ( CPAxisLabel *label in axisLabels ) {
            [label.contentLayer removeFromSuperlayer];
        }
		
		[newLabels retain];
        [axisLabels release];
        axisLabels = newLabels;
		
		[self.plotArea updateAxisSetLayersForType:CPGraphLayerTypeAxisLabels];

		if ( axisLabels ) {
			CPAxisLabelGroup *axisLabelGroup = self.plotArea.axisLabelGroup;
			CALayer *lastLayer = nil;
			
			for ( CPAxisLabel *label in axisLabels ) {
				label.axis = self;
				CPLayer *contentLayer = label.contentLayer;
				if ( contentLayer ) {
					if ( lastLayer ) {
						[axisLabelGroup insertSublayer:contentLayer below:lastLayer];
					}
					else {
						[axisLabelGroup insertSublayer:contentLayer atIndex:[self.plotArea sublayerIndexForAxis:self layerType:CPGraphLayerTypeAxisLabels]];
					}
					
					lastLayer = contentLayer;
				}
			}
		}
		
		[self setNeedsLayout];		
	}
}

-(void)setLabelTextStyle:(CPTextStyle *)newStyle 
{
	if ( newStyle != labelTextStyle ) {
		[labelTextStyle release];
		labelTextStyle = [newStyle copy];
		
		for ( CPAxisLabel *axisLabel in self.axisLabels ) {
			CPLayer *contentLayer = axisLabel.contentLayer;
			if ( [contentLayer isKindOfClass:[CPTextLayer class]] ) {
				[(CPTextLayer *)contentLayer setTextStyle:labelTextStyle];
			}
		}
		
		[self setNeedsLayout];
	}
}

-(void)setAxisTitle:(CPAxisTitle *)newTitle
{
	if ( newTitle != axisTitle ) {
		[axisTitle.contentLayer removeFromSuperlayer];
		[axisTitle release];
		axisTitle = [newTitle retain];
		
		[self.plotArea updateAxisSetLayersForType:CPGraphLayerTypeAxisTitles];
		
		if ( axisTitle ) {
			axisTitle.axis = self;
			axisTitle.offset = self.titleOffset;		
			CPLayer *contentLayer = axisTitle.contentLayer;
			if ( contentLayer ) {
				[self.plotArea.axisTitleGroup insertSublayer:contentLayer atIndex:[self.plotArea sublayerIndexForAxis:self layerType:CPGraphLayerTypeAxisTitles]];
			}
		}
		[self setNeedsLayout];
	}
}

-(CPAxisTitle *)axisTitle 
{
    if ( axisTitle == nil && title != nil ) {
        CPAxisTitle *newTitle = [[CPAxisTitle alloc] initWithText:title textStyle:self.titleTextStyle];
		self.axisTitle = newTitle;
		[newTitle release];
    }
    return axisTitle;
}

-(void)setTitleTextStyle:(CPTextStyle *)newStyle 
{
	if ( newStyle != titleTextStyle ) {
		[titleTextStyle release];
		titleTextStyle = [newStyle copy];

		CPLayer *contentLayer = self.axisTitle.contentLayer;
		if ( [contentLayer isKindOfClass:[CPTextLayer class]] ) {
			[(CPTextLayer *)contentLayer setTextStyle:titleTextStyle];
		}
		
		[self setNeedsLayout];
	}
}

-(void)setTitleOffset:(CGFloat)newOffset 
{
    if ( newOffset != titleOffset ) {
        titleOffset = newOffset;
		self.axisTitle.offset = titleOffset;
		[self setNeedsLayout];
    }
}

-(void)setTitle:(NSString *)newTitle
{
	if ( newTitle != title ) {
		[title release];
		title = [newTitle copy];
    	if ( title == nil ) self.axisTitle = nil;
        
        CPLayer *contentLayer = self.axisTitle.contentLayer;
        if ( [contentLayer isKindOfClass:[CPTextLayer class]] ) {
            [(CPTextLayer *)contentLayer setText:title];
        }
        
		[self setNeedsLayout];
	}
}

-(void)setTitleLocation:(NSDecimal)newLocation
{
	if ( NSDecimalCompare(&newLocation, &titleLocation) != NSOrderedSame ) {
		titleLocation = newLocation;
		[self setNeedsLayout];
	}
}

-(NSDecimal)titleLocation
{
	if ( NSDecimalIsNotANumber(&titleLocation) ) {
		return self.defaultTitleLocation;
	} else {
		return titleLocation;
	}
}

-(void)setLabelExclusionRanges:(NSArray *)ranges 
{
	if ( ranges != labelExclusionRanges ) {
		[labelExclusionRanges release];
		labelExclusionRanges = [ranges retain];
        self.needsRelabel = YES;
	}
}

-(void)setNeedsRelabel:(BOOL)newNeedsRelabel 
{
    if (newNeedsRelabel != needsRelabel) {
        needsRelabel = newNeedsRelabel;
        if ( needsRelabel ) {
            [self setNeedsLayout];
            [self setNeedsDisplay];
        }
    }
}

-(void)setMajorTickLocations:(NSSet *)newLocations 
{
    if ( newLocations != majorTickLocations ) {
        [majorTickLocations release];
        majorTickLocations = [newLocations retain];
		[self setNeedsDisplay];
		if ( self.separateLayers ) {
			[self.majorGridLines setNeedsDisplay];
		}
		else {
			[self.plotArea.majorGridLineGroup setNeedsDisplay];
		}

        self.needsRelabel = YES;
    }
}

-(void)setMinorTickLocations:(NSSet *)newLocations 
{
    if ( newLocations != majorTickLocations ) {
        [minorTickLocations release];
        minorTickLocations = [newLocations retain];
		[self setNeedsDisplay];
		if ( self.separateLayers ) {
			[self.minorGridLines setNeedsDisplay];
		}
		else {
			[self.plotArea.minorGridLineGroup setNeedsDisplay];
		}

        self.needsRelabel = YES;
    }
}

-(void)setMajorTickLength:(CGFloat)newLength 
{
    if ( newLength != majorTickLength ) {
        majorTickLength = newLength;
        [self setNeedsDisplay];
        self.needsRelabel = YES;
    }
}

-(void)setMinorTickLength:(CGFloat)newLength 
{
    if ( newLength != minorTickLength ) {
        minorTickLength = newLength;
        [self setNeedsDisplay];
    }
}

-(void)setLabelOffset:(CGFloat)newOffset 
{
    if ( newOffset != labelOffset ) {
        labelOffset = newOffset;
		[self setNeedsLayout];
        self.needsRelabel = YES;
    }
}

-(void)setLabelRotation:(CGFloat)newRotation 
{
    if ( newRotation != labelRotation ) {
        labelRotation = newRotation;
		[self setNeedsLayout];
        self.needsRelabel = YES;
    }
}

-(void)setPlotSpace:(CPPlotSpace *)newSpace 
{
    if ( newSpace != plotSpace ) {
        [plotSpace release];
        plotSpace = [newSpace retain];
        self.needsRelabel = YES;
    }
}

-(void)setCoordinate:(CPCoordinate)newCoordinate 
{
    if ( newCoordinate != coordinate ) {
        coordinate = newCoordinate;
        self.needsRelabel = YES;
    }
}

-(void)setAxisLineStyle:(CPLineStyle *)newLineStyle 
{
    if ( newLineStyle != axisLineStyle ) {
        [axisLineStyle release];
        axisLineStyle = [newLineStyle copy];
		[self setNeedsDisplay];			
    }
}

-(void)setMajorTickLineStyle:(CPLineStyle *)newLineStyle 
{
    if ( newLineStyle != majorTickLineStyle ) {
        [majorTickLineStyle release];
        majorTickLineStyle = [newLineStyle copy];
        [self setNeedsDisplay];
    }
}

-(void)setMinorTickLineStyle:(CPLineStyle *)newLineStyle 
{
    if ( newLineStyle != minorTickLineStyle ) {
        [minorTickLineStyle release];
        minorTickLineStyle = [newLineStyle copy];
        [self setNeedsDisplay];
    }
}

-(void)setMajorGridLineStyle:(CPLineStyle *)newLineStyle 
{
    if ( newLineStyle != majorGridLineStyle ) {
        [majorGridLineStyle release];
        majorGridLineStyle = [newLineStyle copy];
		
		[self.plotArea updateAxisSetLayersForType:CPGraphLayerTypeMajorGridLines];
		
		if ( majorGridLineStyle ) {
			if ( self.separateLayers ) {
				if ( !self.majorGridLines ) {
					CPGridLines *gridLines = [[CPGridLines alloc] init];
					self.majorGridLines = gridLines;
					[gridLines release];
				}
				else {
					[self.majorGridLines setNeedsDisplay];
				}
			}
			else {
				[self.plotArea.majorGridLineGroup setNeedsDisplay];
			}
		}
		else {
			self.majorGridLines = nil;
		}
    }
}

-(void)setMinorGridLineStyle:(CPLineStyle *)newLineStyle 
{
    if ( newLineStyle != minorGridLineStyle ) {
        [minorGridLineStyle release];
        minorGridLineStyle = [newLineStyle copy];
		
		[self.plotArea updateAxisSetLayersForType:CPGraphLayerTypeMinorGridLines];
		
		if ( minorGridLineStyle ) {
			if ( self.separateLayers ) {
				if ( !self.minorGridLines ) {
					CPGridLines *gridLines = [[CPGridLines alloc] init];
					self.minorGridLines = gridLines;
					[gridLines release];
				}
				else {
					[self.minorGridLines setNeedsDisplay];
				}
			}
			else {
				[self.plotArea.minorGridLineGroup setNeedsDisplay];
			}
		}
		else {
			self.minorGridLines = nil;
		}
    }
}

-(void)setLabelingOrigin:(NSDecimal)newLabelingOrigin
{
	if ( CPDecimalEquals(labelingOrigin, newLabelingOrigin) ) {
		return;
	}
	labelingOrigin = newLabelingOrigin;
	self.needsRelabel = YES;
}

-(void)setMajorIntervalLength:(NSDecimal)newIntervalLength 
{
	if ( CPDecimalEquals(majorIntervalLength, newIntervalLength) ) {
		return;
	}
	majorIntervalLength = newIntervalLength;
	self.needsRelabel = YES;
}

-(void)setMinorTicksPerInterval:(NSUInteger)newMinorTicksPerInterval 
{
    if ( newMinorTicksPerInterval != minorTicksPerInterval ) {
        minorTicksPerInterval = newMinorTicksPerInterval;
        self.needsRelabel = YES;
    }
}

-(void)setLabelingPolicy:(CPAxisLabelingPolicy)newPolicy 
{
    if ( newPolicy != labelingPolicy ) {
        labelingPolicy = newPolicy;
        self.needsRelabel = YES;
    }
}

-(void)setLabelFormatter:(NSNumberFormatter *)newTickLabelFormatter 
{
    if ( newTickLabelFormatter != labelFormatter ) {
        [labelFormatter release];
        labelFormatter = [newTickLabelFormatter retain];
		self.labelFormatterChanged = YES;
        self.needsRelabel = YES;
    }
}

-(void)setTickDirection:(CPSign)newDirection 
{
    if ( newDirection != tickDirection ) {
        tickDirection = newDirection;
		[self setNeedsLayout];
        self.needsRelabel = YES;
    }
}

-(void)setGridLinesRange:(CPPlotRange *)newRange {
    if ( newRange != gridLinesRange ) {
        [gridLinesRange release];
        gridLinesRange = [newRange copy];
		if ( self.separateLayers ) {
			[self.minorGridLines setNeedsDisplay];
			[self.majorGridLines setNeedsDisplay];
		}
		else {
			[self.plotArea.minorGridLineGroup setNeedsDisplay];
			[self.plotArea.majorGridLineGroup setNeedsDisplay];
		}
    }
}

-(void)setPlotArea:(CPPlotArea *)newPlotArea
{
	if ( newPlotArea != plotArea ) {
		plotArea = newPlotArea;
		
		if ( plotArea ) {
			[plotArea updateAxisSetLayersForType:CPGraphLayerTypeMinorGridLines];
			if ( self.minorGridLines ) {
				[self.minorGridLines removeFromSuperlayer];
				[plotArea.minorGridLineGroup insertSublayer:minorGridLines atIndex:[plotArea sublayerIndexForAxis:self layerType:CPGraphLayerTypeMinorGridLines]];
			}
			
			[plotArea updateAxisSetLayersForType:CPGraphLayerTypeMajorGridLines];
			if ( self.majorGridLines ) {
				[self.majorGridLines removeFromSuperlayer];
				[plotArea.majorGridLineGroup insertSublayer:majorGridLines atIndex:[plotArea sublayerIndexForAxis:self layerType:CPGraphLayerTypeMajorGridLines]];
			}
			
			[plotArea updateAxisSetLayersForType:CPGraphLayerTypeAxisLabels];
			if ( self.axisLabels.count > 0 ) {
				CPAxisLabelGroup *axisLabelGroup = self.plotArea.axisLabelGroup;
				CALayer *lastLayer = nil;
				
				for ( CPAxisLabel *label in axisLabels ) {
					label.axis = self;
					CPLayer *contentLayer = label.contentLayer;
					if ( contentLayer ) {
						[contentLayer removeFromSuperlayer];
						
						if ( lastLayer ) {
							[axisLabelGroup insertSublayer:contentLayer below:lastLayer];
						}
						else {
							[axisLabelGroup insertSublayer:contentLayer atIndex:[self.plotArea sublayerIndexForAxis:self layerType:CPGraphLayerTypeAxisLabels]];
						}
						
						lastLayer = contentLayer;
					}
				}
			}
			
			[plotArea updateAxisSetLayersForType:CPGraphLayerTypeAxisTitles];
			if ( self.axisTitle.contentLayer ) {
				[self.axisTitle.contentLayer removeFromSuperlayer];
				[plotArea.axisTitleGroup insertSublayer:self.axisTitle.contentLayer atIndex:[plotArea sublayerIndexForAxis:self layerType:CPGraphLayerTypeAxisTitles]];
			}
		}
	}	
}

-(void)setVisibleRange:(CPPlotRange *)newRange
{
    if ( newRange != visibleRange ) {
        [visibleRange release];
        visibleRange = [newRange copy];
        self.needsRelabel = YES;
    }
}

-(void)setSeparateLayers:(BOOL)newSeparateLayers
{
	if ( newSeparateLayers != separateLayers ) {
		separateLayers = newSeparateLayers;
		if ( separateLayers ) {
			if ( self.minorGridLineStyle ) {
				CPGridLines *gridLines = [[CPGridLines alloc] init];
				self.minorGridLines = gridLines;
				[gridLines release];
			}
			if ( self.majorGridLineStyle ) {
				CPGridLines *gridLines = [[CPGridLines alloc] init];
				self.majorGridLines = gridLines;
				[gridLines release];
			}
		}
		else {
			self.minorGridLines	= nil;
			if ( self.minorGridLineStyle ) {
				[self.plotArea.minorGridLineGroup setNeedsDisplay];
			}
			self.majorGridLines = nil;
			if ( self.majorGridLineStyle ) {
				[self.plotArea.majorGridLineGroup setNeedsDisplay];
			}
		}
		
	}
}

-(void)setMinorGridLines:(CPGridLines *)newGridLines
{
	if ( newGridLines != minorGridLines ) {
		[minorGridLines removeFromSuperlayer];
		minorGridLines = newGridLines;
		if ( minorGridLines ) {
			minorGridLines.major = NO;
			minorGridLines.axis = self;
			[self.plotArea.minorGridLineGroup insertSublayer:minorGridLines atIndex:[self.plotArea sublayerIndexForAxis:self layerType:CPGraphLayerTypeMinorGridLines]];
		}
	}
}

-(void)setMajorGridLines:(CPGridLines *)newGridLines
{
	if ( newGridLines != majorGridLines ) {
		[majorGridLines removeFromSuperlayer];
		majorGridLines = newGridLines;
		if ( majorGridLines ) {
			majorGridLines.major = YES;
			majorGridLines.axis = self;
			[self.plotArea.majorGridLineGroup insertSublayer:majorGridLines atIndex:[self.plotArea sublayerIndexForAxis:self layerType:CPGraphLayerTypeMajorGridLines]];
		}
	}	
}

-(CPAxisSet *)axisSet
{
	return self.plotArea.axisSet;
}

@end

#pragma mark -

@implementation CPAxis(AbstractMethods)

/**	@brief Converts a position on the axis to drawing coordinates.
 *	@param coordinateDecimalNumber The axis value in data coordinate space.
 *	@return The drawing coordinates of the point.
 **/
-(CGPoint)viewPointForCoordinateDecimalNumber:(NSDecimal)coordinateDecimalNumber
{
	return CGPointZero;
}

/**	@brief Draws grid lines into the provided graphics context.
 *	@param context The graphics context to draw into.
 *	@param major Draw the major grid lines if YES, minor grid lines otherwise.
 **/
-(void)drawGridLinesInContext:(CGContextRef)context isMajor:(BOOL)major
{
	// do nothing--subclasses must override to do their drawing	
}

@end
