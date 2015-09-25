//
//  F3Swirly.m
//  Copyright (c) 2012 by Brad Benson
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following
//  conditions are met:
//    1.  Redistributions of source code must retain the above copyright
//        notice this list of conditions and the following disclaimer.
//    2.  Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in
//        the documentation and/or other materials provided with the
//        distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
//  COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
//  OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
//  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
//  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
//  OF SUCH DAMAGE.
//


//---> Get required headers <---------------------------------------------
#import "F3Swirly.h"


#pragma mark - Threshold Class (private-ish)
//------------------------------------------------------------------------
//------------------------------------------------------------------------
//------------|  F3SwirlyThreshold class implementation  |----------------
//------------------------------------------------------------------------
//------------------------------------------------------------------------

//===[ Class definition ]=================================================
@interface F3SwirlyThreshold : NSObject

// Properties
@property (nonatomic, readwrite) double value;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, readwrite) int rpm;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, readwrite) int segments;

// Initialization
-(id) init:(double) a_flValue
 withColor:(UIColor *)a_color;

@end


//===[ Implementation ]===================================================
@implementation F3SwirlyThreshold

//------------------------------------------------------------------------
//  Method: init:withColor:andText:
//    Designated initializer
//
-(id) init:(double)a_flValue
 withColor:(UIColor *)a_color
{
    // Call parent
    self = [super init];
    if(self) {
        // Initialize instance variables
        _value      = a_flValue;
        _color      = a_color;
        _rpm        = 0;
        _label      = nil;
        _segments   = 2;
    }
    
    // Done!
    return self;
}


//------------------------------------------------------------------------
//  Method: dealloc
//    Called when instance is released
//
@end



#pragma mark - Layer Delegate (private-ish)
//------------------------------------------------------------------------
//------------------------------------------------------------------------
//------------|  F3SwirlyLayerDelegate class implementation  |------------
//------------------------------------------------------------------------
//------------------------------------------------------------------------

//===[ Class definition ]=================================================
@interface F3SwirlyLayerDelegate : NSObject
{
    id      _target;
}

// Initialization
-(id) initWithView:(id) a_target;
@end

//===[ Implementation ]===================================================
@implementation F3SwirlyLayerDelegate;

//------------------------------------------------------------------------
//  Method: initWithView:action:
//    Designated initializer
//
-(id) initWithView:(id) a_target
{
    // Call super
    self = [super init];
    if(self) {
        // Initialize instance data
        _target = a_target;
    }
    
    // Done!
    return self;
}


//------------------------------------------------------------------------
//  Method: drawLayer:inContext:
//    Catches delegated calls and passes them to view
-(void) drawLayer:(CALayer *)a_layer
        inContext:(CGContextRef)a_ctx
{
    // Call defined view
    [_target drawLayer:a_layer inContext:a_ctx];
}


@end


#pragma mark - Class Implementation
//------------------------------------------------------------------------
//------------------------------------------------------------------------
//-----------------|  F3Swirly class implementation  |--------------------
//------------------------------------------------------------------------
//------------------------------------------------------------------------

//===[ Class extension for private stuff ]================================
@interface F3Swirly()
{
    BOOL                      _fRoundedSegments;   // true = segments have rounded ends
    CGFloat                   _flValue,            // Current value being shown
                              _flThickness;        // Thickness of swirly
    int                       _iSegments;          // Number of segments
    int                       _iCurrentRpm;        // Current RPM of swirly
    CALayer                   *_swirlyLayer;       // Layer containing the animated swirly
    CABasicAnimation          *_swirlyAnim,        // Swirly animation object (continuous)
                              *_transitionAnim;    // Transition animation object
    F3SwirlyThreshold         *_currentThreshold;  // Current threshold (value/color) object
    F3SwirlyLayerDelegate     *_layerDelegate;     // Layer delegate
    NSMutableArray            *_aThresholds;       // Array of threshold objects
}

@end


//===[ Public methods ]===================================================
@implementation F3Swirly


#pragma mark - View lifecyle
//------------------------------------------------------------------------
//  Method: initWithFrame:
//    Initialization method
//
- (id)initWithFrame:(CGRect)frame
{
    // Call parent method
    self = [super initWithFrame:frame];
    if (self) {
        // Initialize instance values
        [self setDefaults];
        [self createLayers];
    }
    
    // Done!
    return self;
}


//------------------------------------------------------------------------
//  Method: initWithCoder:
//    Initializes the instance when brought from nib, etc.
//
-(id) initWithCoder:(NSCoder *)aDecoder
{
    // Call parent method
    self = [super initWithCoder:aDecoder];
    if(self) {
        // Initialize instance values
        [self setDefaults];
        [self createLayers];
    }
    
    // Done!
    return self;
}


//------------------------------------------------------------------------
//  Method: layoutSubviews
//    This method is invoked when the view needs to adjust the layout
//    of its subviews.   We'll use this opportunity to adjust the
//    swirly layer as well, adjusting it as needed for the new size.
//
-(void) layoutSubviews
{
    // Adjust size/pos and re-paint layer
    _swirlyLayer.frame = self.bounds;
    _swirlyLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [_swirlyLayer setNeedsDisplay];
    
    // Pass the message on up the chain
    [super layoutSubviews];
}


//------------------------------------------------------------------------
//  Method: dealloc
//    Clean up the instance when it is released
//
- (void) dealloc
{
    // Pull layers out for cleanup
    [_swirlyLayer removeAnimationForKey:@"swirly"];
    [_swirlyLayer removeFromSuperlayer];
}


#pragma mark - Value and Thresholds
//------------------------------------------------------------------------
//  Method: setValue:
//    Sets the value associated with the instance and requests
//    a re-draw if the threshold value has changed.
//
-(void) setValue:(CGFloat)a_flValue
{
    F3SwirlyThreshold       *idThreshold;   // New threshold
    
    // Find the appropriate threshold value
    idThreshold = [self findThreshold:a_flValue];
    
    // Different than last time?
    if( idThreshold != _currentThreshold ) {
        // Yes, save new one and update
        _currentThreshold = idThreshold;
        self.text = (_currentThreshold.label) ? _currentThreshold.label : @"";
        [_swirlyLayer setNeedsDisplay];
        
        // Is RPM non-zero?
        if( _currentThreshold.rpm != 0 ) {
            // Yes, do some animation
            [self startSwirly:_currentThreshold.rpm];
        }
        else {
            // No, stop it
            [self stopSwirly];
        }
    }
}


//------------------------------------------------------------------------
//  Method: addThreshold:withColor:
//    Adds a threshold with a specific color and text label
//
- (void) addThreshold:(double)a_flValue
            withColor:(UIColor *)a_color
{
    // Do it
    [self addThreshold:a_flValue
             withColor:a_color
                   rpm:60
                 label:nil
              segments:-1];
}



//------------------------------------------------------------------------
//  Method: addThreshold:withColor:rpm:label:
//    Adds a threshold with a specific color and text label
//
- (void) addThreshold:(double)a_flValue
            withColor:(UIColor *)a_color
                  rpm:(int) a_iRpm
                label:(NSString *)a_strLabel
{
    // Do it
    [self addThreshold:a_flValue
             withColor:a_color
                   rpm:a_iRpm
                 label:a_strLabel
              segments:-1];
}


//------------------------------------------------------------------------
//  Method: addThreshold:withColor:rpm:label:segments:
//
- (void) addThreshold:(double)a_flValue
            withColor:(UIColor *)a_color
                  rpm:(int)a_iRpm
                label:(NSString *)a_strLabel
             segments:(int) a_iSegments

{
    // Initialize a new threshold object and add it to the array
    F3SwirlyThreshold *t = [[F3SwirlyThreshold alloc] init:a_flValue
                                                 withColor:a_color];
    t.rpm       = a_iRpm;
    t.label     = a_strLabel;
    t.segments  = a_iSegments;
    [_aThresholds addObject:t];
    
    // Sort the threshold array by value
    [_aThresholds sortUsingComparator:^NSComparisonResult(id  _Nonnull a_obj1, id  _Nonnull a_obj2) {
        return ((F3SwirlyThreshold *)a_obj1).value > ((F3SwirlyThreshold *)a_obj2).value;
    }];
}


//===[ Private methods ]==================================================


#pragma mark - Initialization items

//------------------------------------------------------------------------
//  Method: setDefaults
//    Initialize instance values
//
-(void) setDefaults
{
    // Initialization code
    _flValue           = 0.0;
    _flThickness       = 15.0f;
    _iSegments         = 2;
    _iCurrentRpm       = 0;
    _fRoundedSegments  = YES;
    _aThresholds       = [[NSMutableArray alloc] init];
    
    // Set up label attributes
    [self setTextAlignment:UITextAlignmentCenter];
}


//------------------------------------------------------------------------
//  Method: createLayers
//    Create and initialize CALayer instances
//
-(void) createLayers
{
    // Create the delegate for handling layer drawing
    // ... The UIView instance cannot be a direct delegate
    // ... so we create one to proxy delegate items back to the
    // ... view instance.
    _layerDelegate = [[F3SwirlyLayerDelegate alloc] initWithView:self];
    
    // Create the layer and add delegate
    _swirlyLayer = [CALayer layer];
    _swirlyLayer.frame = self.bounds;
    _swirlyLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _swirlyLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _swirlyLayer.delegate = _layerDelegate;
    _swirlyLayer.masksToBounds = YES;
    [self.layer addSublayer:_swirlyLayer];
    
    // Create continuous animation object for swirly
    _swirlyAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    _swirlyAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    _swirlyAnim.repeatCount = HUGE_VALF;
    _swirlyAnim.delegate = self;
    _swirlyAnim.fillMode = kCAFillModeForwards;
    _swirlyAnim.removedOnCompletion = NO;
    [_swirlyAnim setValue:@"continuous" forKey:@"animationType"];
    
    // Create transition animation object
    _transitionAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    _transitionAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    _transitionAnim.repeatCount = 1;
    _transitionAnim.fillMode = kCAFillModeForwards;
    _transitionAnim.removedOnCompletion = NO;
    _transitionAnim.delegate = self;
    [_transitionAnim setValue:@"transition" forKey:@"animationType"];
    
    // Make sure the swirly is visible!
    self.opaque = NO;
    self.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.layer.opaque = NO;
}


//------------------------------------------------------------------------
//  Method: findThreshold:
//    This method returns the best match threshold for the supplied
//    value.
//
- (id) findThreshold:(double) a_flValue
{
    F3SwirlyThreshold   *idResult = nil;      // Result value
    
    // Find closest match which doesn't go over
    //    Simple O(n) implementation ok for a few (<5) thresholds.
    for (F3SwirlyThreshold *t in _aThresholds) {
        // New max?
        if( a_flValue < t.value ) {
            break;
        }
        idResult = t;
    }
    
    // Return the result
    return idResult;
}


#pragma mark - Drawing and Animation
//------------------------------------------------------------------------
//  Method: drawLayer:inContext:
//    This method draws the specified layer using the supplied
//    graphics context.  The only layer currently managed is
//    the layer containing the swirly.
//
-(void)drawLayer:(CALayer *)a_layer
       inContext:(CGContextRef)a_ctx
{
    CGFloat         flCenterX,              // X position for drawing
    flCenterY,              // Y position for drawing
    flRadius,               // Arc radius
    flStart,                // Start point
    flEnd,                  // End point
    flStep;                 // Segment length
    int             iSegments;              // Number of segments
    
    // Is this the swirly layer?
    if(a_layer == _swirlyLayer) {
        // Get drawing info
        flCenterX = self.bounds.size.width / 2;
        flCenterY = self.bounds.size.height / 2;
        flRadius = MIN(flCenterX, flCenterY) - 5;
        iSegments = (_currentThreshold && _currentThreshold.segments < 0) ?
        _iSegments :
        _currentThreshold.segments;
        
        // Prep for drawing
        CGContextSetStrokeColorWithColor(a_ctx, _currentThreshold.color.CGColor);
        CGContextSetLineWidth(a_ctx, _flThickness);
        CGContextSetLineCap(a_ctx,
                            (_fRoundedSegments) ? kCGLineCapRound : kCGLineCapButt);
        CGContextSetShadowWithColor(a_ctx,
                                    CGSizeMake(0, 0),
                                    8.0,
                                    [UIColor blackColor].CGColor);
        CGContextBeginPath(a_ctx);
        
        // Draw arc segments
        flStart = 0.0;
        flStep = M_PI*2 / iSegments / 2;
        for(int iX = 0; iX < iSegments; ++ iX) {
            // Compute new end point for arc
            flEnd = flStart + flStep;
            
            // Draw the arc
            CGContextMoveToPoint(a_ctx,
                                 flCenterX + cos(flStart) * (flRadius - _flThickness/2),
                                 flCenterY + sin(flStart) * (flRadius - _flThickness/2));
            CGContextAddArc(a_ctx,
                            flCenterX, flCenterY, flRadius - (_flThickness/2),
                            flStart, flEnd, NO);
            
            // Update for next iteration
            flStart = flEnd + flStep;
        }
        
        // Stroke the path
        CGContextStrokePath(a_ctx);
    }
    else {
        // Pass it on
        [super drawLayer:a_layer inContext:a_ctx];
    }
}


//------------------------------------------------------------------------
//  Method: animationDidStop:finished:
//    Called by the animation object when the animation is stopped
//    either because it is done or because it was canceled.
//
-(void) animationDidStop:(CAAnimation *)a_anim
                finished:(BOOL)a_fFinished
{
    // Is the ending animation the transition one?
    if( [[a_anim valueForKey:@"animationType"] isEqualToString:@"transition"] &&
       _currentThreshold.rpm != 0 ) {
        // Yes, start the continuous one
        [_swirlyLayer addAnimation:_swirlyAnim forKey:@"swirly"];
    }
}


//------------------------------------------------------------------------
//  Method: startSwirly:
//    Starts animation at the specified rate
//
-(void) startSwirly:(int)a_iRpm
{
    float       flStart,            // Starting point
    flEnd,              // Animation end point
    flDuration;         // Duration of animation
    
    // Configure continuous animation
    flStart     = 0.0f;
    flEnd       = (_currentThreshold.rpm > 0) ? M_PI*2.0f : -M_PI*2.0f;    // Negative for counter-clockwise
    flDuration  = 1.0 / (abs(a_iRpm) / 60.0);
    _swirlyAnim.fromValue = [NSNumber numberWithFloat:flStart];
    _swirlyAnim.toValue = [NSNumber numberWithFloat:flEnd];
    _swirlyAnim.duration = flDuration;
    
    // Configure transition animation and start it
    // ... Start from present position, pro-rate duration to account for partial rotation
    flStart = ((NSNumber *)[[_swirlyLayer presentationLayer] valueForKeyPath:@"transform.rotation.z"]).floatValue;
    flDuration *= fabs(flEnd - flStart) / (M_PI * 2);
    _transitionAnim.fromValue = [[_swirlyLayer presentationLayer] valueForKeyPath:@"transform.rotation.z"];
    _transitionAnim.timingFunction = (_iCurrentRpm == 0) ?
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]:
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    _transitionAnim.toValue = [NSNumber numberWithFloat:flEnd];
    _transitionAnim.duration = flDuration;
    [_swirlyLayer addAnimation:_transitionAnim forKey:@"swirly"];
    
    // Update for next time
    _iCurrentRpm = a_iRpm;
}


//------------------------------------------------------------------------
//  Method: stopSwirly
//    Stops animation
//
-(void) stopSwirly
{
    float       flStart,            // Starting point
    flEnd,              // Animation end point
    flDuration;         // Duration of animation
    
    // Start position for animation is current position on presentation layer
    flStart = ((NSNumber *)[[_swirlyLayer presentationLayer] valueForKeyPath:@"transform.rotation.z"]).floatValue;
    
    // Ending position is starting position plus 1/8 turn
    flEnd = (_iCurrentRpm > 0) ?
    flStart + M_PI/4 :
    flStart - M_PI/4;
    
    // Duration is RPM pro-rated for partial turn
    flDuration  = 1.0 / (abs(_iCurrentRpm) / 60.0);
    flDuration *= fabs(flEnd - flStart) / (M_PI * 2);
    
    // Configure transition animation and start it
    _transitionAnim.fromValue = [[_swirlyLayer presentationLayer] valueForKeyPath:@"transform.rotation.z"];
    _transitionAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    _transitionAnim.toValue = [NSNumber numberWithFloat:flEnd];
    _transitionAnim.duration = flDuration;
    [_swirlyLayer addAnimation:_transitionAnim forKey:@"swirly"];
}



@end

