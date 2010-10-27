#import "CPColor.h"
#import "CPColorSpace.h"
#import "CPPlatformSpecificFunctions.h"

/** @brief Wrapper around CGColorRef
 *
 *  A wrapper class around CGColorRef
 *
 * @todo More documentation needed 
 **/

@implementation CPColor

/** @property cgColor
 *  @brief The CGColor to wrap around.
 **/
@synthesize cgColor;

#pragma mark -
#pragma mark Factory Methods

/** @brief Returns a shared instance of CPColor initialized with a fully transparent color.
 *
 *  @return A shared CPColor object initialized with a fully transparent color.
 **/
+(CPColor *)clearColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
        CGColorRef clear = NULL;
        CGFloat values[4] = {0.0, 0.0, 0.0, 0.0}; 
		clear = CGColorCreate([CPColorSpace genericRGBSpace].cgColorSpace, values); 
        color = [[CPColor alloc] initWithCGColor:clear];
        CGColorRelease(clear);
    }
	return color; 
} 

/** @brief Returns a shared instance of CPColor initialized with a fully opaque white color.
 *
 *  @return A shared CPColor object initialized with a fully opaque white color.
 **/
+(CPColor *)whiteColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
        color = [[self colorWithGenericGray:1.0] retain];
    }
	return color; 
} 

/** @brief Returns a shared instance of CPColor initialized with a fully opaque 2/3 gray color.
 *
 *  @return A shared CPColor object initialized with a fully opaque 2/3 gray color.
 **/
+(CPColor *)lightGrayColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
		color = [[self colorWithGenericGray:2.0/3.0] retain];
    }
	return color; 
}

/** @brief Returns a shared instance of CPColor initialized with a fully opaque 50% gray color.
 *
 *  @return A shared CPColor object initialized with a fully opaque 50% gray color.
 **/
+(CPColor *)grayColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
        color = [[self colorWithGenericGray:0.5] retain];
    }
	return color; 
}

/** @brief Returns a shared instance of CPColor initialized with a fully opaque 1/3 gray color.
 *
 *  @return A shared CPColor object initialized with a fully opaque 1/3 gray color.
 **/
+(CPColor *)darkGrayColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
        color = [[self colorWithGenericGray:1.0/3.0] retain];
    }
	return color; 
}

/** @brief Returns a shared instance of CPColor initialized with a fully opaque black color.
 *
 *  @return A shared CPColor object initialized with a fully opaque black color.
 **/
+(CPColor *)blackColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
        color = [[self colorWithGenericGray:0.0] retain];
    }
	return color; 
} 

/** @brief Returns a shared instance of CPColor initialized with a fully opaque red color.
 *
 *  @return A shared CPColor object initialized with a fully opaque red color.
 **/
+(CPColor *)redColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
		color = [[CPColor alloc] initWithComponentRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    }
	return color; 
} 

/** @brief Returns a shared instance of CPColor initialized with a fully opaque green color.
 *
 *  @return A shared CPColor object initialized with a fully opaque green color.
 **/
+(CPColor *)greenColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
		color = [[CPColor alloc] initWithComponentRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    }
	return color; 
}

/** @brief Returns a shared instance of CPColor initialized with a fully opaque blue color.
 *
 *  @return A shared CPColor object initialized with a fully opaque blue color.
 **/
+(CPColor *)blueColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
		color = [[CPColor alloc] initWithComponentRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    }
	return color; 
}

/** @brief Returns a shared instance of CPColor initialized with a fully opaque cyan color.
 *
 *  @return A shared CPColor object initialized with a fully opaque cyan color.
 **/
+(CPColor *)cyanColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
		color = [[CPColor alloc] initWithComponentRed:0.0 green:1.0 blue:1.0 alpha:1.0];
    }
	return color; 
}

/** @brief Returns a shared instance of CPColor initialized with a fully opaque yellow color.
 *
 *  @return A shared CPColor object initialized with a fully opaque yellow color.
 **/
+(CPColor *)yellowColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
		color = [[CPColor alloc] initWithComponentRed:1.0 green:1.0 blue:0.0 alpha:1.0];
    }
	return color; 
}

/** @brief Returns a shared instance of CPColor initialized with a fully opaque magenta color.
 *
 *  @return A shared CPColor object initialized with a fully opaque magenta color.
 **/
+(CPColor *)magentaColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
		color = [[CPColor alloc] initWithComponentRed:1.0 green:0.0 blue:1.0 alpha:1.0];
    }
	return color; 
}

/** @brief Returns a shared instance of CPColor initialized with a fully opaque orange color.
 *
 *  @return A shared CPColor object initialized with a fully opaque orange color.
 **/
+(CPColor *)orangeColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
		color = [[CPColor alloc] initWithComponentRed:1.0 green:0.5 blue:0.0 alpha:1.0];
    }
	return color; 
}

/** @brief Returns a shared instance of CPColor initialized with a fully opaque purple color.
 *
 *  @return A shared CPColor object initialized with a fully opaque purple color.
 **/
+(CPColor *)purpleColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
		color = [[CPColor alloc] initWithComponentRed:0.5 green:0.0 blue:0.5 alpha:1.0];
    }
	return color; 
}

/** @brief Returns a shared instance of CPColor initialized with a fully opaque brown color.
 *
 *  @return A shared CPColor object initialized with a fully opaque brown color.
 **/
+(CPColor *)brownColor
{ 
    static CPColor *color = nil;
    if ( nil == color ) {
		color = [[CPColor alloc] initWithComponentRed:0.6 green:0.4 blue:0.2 alpha:1.0];
    }
	return color; 
}

/** @brief Creates and returns a new CPColor instance initialized with the provided CGColorRef.
 *  @param newCGColor The color to wrap.
 *  @return A new CPColor instance initialized with the provided CGColorRef.
 **/
+(CPColor *)colorWithCGColor:(CGColorRef)newCGColor 
{
    return [[[CPColor alloc] initWithCGColor:newCGColor] autorelease];
}

/** @brief Creates and returns a new CPColor instance initialized with the provided RGBA color components.
 *  @param red The red component (0 ≤ red ≤ 1).
 *  @param green The green component (0 ≤ green ≤ 1).
 *  @param blue The blue component (0 ≤ blue ≤ 1).
 *  @param alpha The alpha component (0 ≤ alpha ≤ 1).
 *  @return A new CPColor instance initialized with the provided RGBA color components.
 **/
+(CPColor *)colorWithComponentRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    return [[[CPColor alloc] initWithComponentRed:red green:green blue:blue alpha:alpha] autorelease];
}

/** @brief Creates and returns a new CPColor instance initialized with the provided gray level.
 *  @param gray The gray level (0 ≤ gray ≤ 1).
 *  @return A new CPColor instance initialized with the provided gray level.
 **/
+(CPColor *)colorWithGenericGray:(CGFloat)gray
{
	CGFloat values[4] = {gray, gray, gray, 1.0}; 
	CGColorRef colorRef = CGColorCreate([CPColorSpace genericRGBSpace].cgColorSpace, values);
	CPColor *color = [[CPColor alloc] initWithCGColor:colorRef];
	CGColorRelease(colorRef);
	return [color autorelease];
}

#pragma mark -
#pragma mark Initialize/Deallocate

/** @brief Initializes a newly allocated CPColor object with the provided CGColorRef.
 *
 *	@param newCGColor The color to wrap.
 *  @return The initialized CPColor object.
 **/
-(id)initWithCGColor:(CGColorRef)newCGColor
{
    if ( self = [super init] ) {            
        CGColorRetain(newCGColor);
        cgColor = newCGColor;
    }
    return self;
}

/** @brief Initializes a newly allocated CPColor object with the provided RGBA color components.
 *
 *  @param red The red component (0 ≤ red ≤ 1).
 *  @param green The green component (0 ≤ green ≤ 1).
 *  @param blue The blue component (0 ≤ blue ≤ 1).
 *  @param alpha The alpha component (0 ≤ alpha ≤ 1).
 *  @return The initialized CPColor object.
 **/
-(id)initWithComponentRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    CGFloat colorComponents[4];
    colorComponents[0] = red;
    colorComponents[1] = green;
    colorComponents[2] = blue;
    colorComponents[3] = alpha;
    CGColorRef color = CGColorCreate([CPColorSpace genericRGBSpace].cgColorSpace, colorComponents);
    [self initWithCGColor:color];
    CGColorRelease(color);
    return self;
}

-(void)dealloc 
{
    CGColorRelease(cgColor);
    [super dealloc];
}

-(void)finalize
{
    CGColorRelease(cgColor);
	[super finalize];
}

#pragma mark -
#pragma mark Creating colors from other colors

/** @brief Creates and returns a new CPColor instance having color components identical to the current object
 *	but having the provided alpha component.
 *  @param alpha The alpha component (0 ≤ alpha ≤ 1).
 *  @return A new CPColor instance having the provided alpha component.
 **/
-(CPColor *)colorWithAlphaComponent:(CGFloat)alpha
{
    CGColorRef newCGColor = CGColorCreateCopyWithAlpha(self.cgColor, alpha);
    CPColor *newColor = [CPColor colorWithCGColor:newCGColor];
    CGColorRelease(newCGColor);
    return newColor;
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	const CGFloat *colorComponents = CGColorGetComponents(self.cgColor);
	
	[coder encodeDouble:colorComponents[0] forKey:@"redComponent"];
	[coder encodeDouble:colorComponents[1] forKey:@"greenComponent"];
	[coder encodeDouble:colorComponents[2] forKey:@"blueComponent"];
	[coder encodeDouble:colorComponents[3] forKey:@"alphaComponent"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
    
    if (self) {
		CGFloat colorComponents[4];
		colorComponents[0] = [coder decodeDoubleForKey:@"redComponent"];
		colorComponents[1] = [coder decodeDoubleForKey:@"greenComponent"];
		colorComponents[2] = [coder decodeDoubleForKey:@"blueComponent"];
		colorComponents[3] = [coder decodeDoubleForKey:@"alphaComponent"];
		cgColor = CGColorCreate([CPColorSpace genericRGBSpace].cgColorSpace, colorComponents);
	}
    return self;
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
    CGColorRef cgColorCopy = NULL;
    if ( cgColor ) cgColorCopy = CGColorCreateCopy(cgColor);
    CPColor *colorCopy = [[[self class] allocWithZone:zone] initWithCGColor:cgColorCopy];
    CGColorRelease(cgColorCopy);
    return colorCopy;
}

#pragma mark -
#pragma mark Color comparison

-(BOOL)isEqual:(id)object
{
	if ( self == object ) {
		return YES;
	}
	else if ([object isKindOfClass:[self class]]) {
		return CGColorEqualToColor(self.cgColor, ((CPColor *)object).cgColor);
	}
	else {
		return NO;
	}
}

-(NSUInteger)hash
{
	// Equal objects must hash the same.
	CGFloat theHash = 0.0;
	CGFloat multiplier = 256.0;

	CGColorRef theColor = self.cgColor;
	size_t numberOfComponents = CGColorGetNumberOfComponents(theColor);
	const CGFloat *colorComponents = CGColorGetComponents(theColor);
	
	for (NSUInteger i = 0; i < numberOfComponents; i++) {
		theHash += multiplier * colorComponents[i];
		multiplier *= 256.0;
	}
	
	return (NSUInteger)theHash;
}

@end
