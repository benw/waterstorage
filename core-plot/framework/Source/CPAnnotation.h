#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class CPAnnotationHostLayer;
@class CPLayer;

@interface CPAnnotation : NSObject {
@private
	CPAnnotationHostLayer *annotationHostLayer;
	CPLayer *contentLayer;
    CGPoint displacement;
}

@property (nonatomic, readwrite, retain) CPLayer *contentLayer;
@property (nonatomic, readwrite, assign) CPAnnotationHostLayer *annotationHostLayer;
@property (nonatomic, readwrite, assign) CGPoint displacement;

@end

#pragma mark -

/**	@category CPAnnotation(AbstractMethods)
 *	@brief CPAnnotation abstract methods—must be overridden by subclasses.
 **/
@interface CPAnnotation(AbstractMethods)

-(void)positionContentLayer;

@end
