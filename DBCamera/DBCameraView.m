//
//  DBCameraView.m
//  DBCamera
//
//  Created by iBo on 31/01/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraView.h"

#define UIColorFromRGB(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

@interface DBCameraView ()
@property (nonatomic, strong) CALayer *focusBox;
@property (nonatomic, strong) CALayer *exposeBox;
@end

@implementation DBCameraView

- (id) initWithCaptureSession:(AVCaptureSession *)captureSession
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ( self ) {
        [self setBackgroundColor:[UIColor blackColor]];
        
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
        [_previewLayer setFrame:self.bounds];
        
        if ( [_previewLayer respondsToSelector:@selector(connection)] ) {
            if ( [_previewLayer.connection isVideoOrientationSupported] )
                [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        }
        
        [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        [_previewLayer addSublayer:self.focusBox];
        [_previewLayer addSublayer:self.exposeBox];
        [self.layer addSublayer:_previewLayer];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundColor:[UIColor redColor]];
        [button setFrame:(CGRect){ 10, 10, 100, 100 }];
        [button addTarget:_delegate action:@selector(cameraViewStartRecording) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        [self createGesture];
    }
    
    return self;
}

#pragma mark - Focus / Expose Box

- (CALayer *) focusBox
{
    if ( !_focusBox ) {
        _focusBox = [[CALayer alloc] init];
        [_focusBox setCornerRadius:45.0f];
        [_focusBox setBounds:CGRectMake(0.0f, 0.0f, 90, 90)];
        [_focusBox setBorderWidth:5.f];
        [_focusBox setBorderColor:[UIColorFromRGB(0xffffff, 1) CGColor]];
        [_focusBox setOpacity:0];
    }
    
    return _focusBox;
}

- (CALayer *) exposeBox
{
    if ( !_exposeBox ) {
        _exposeBox = [[CALayer alloc] init];
        [_exposeBox setCornerRadius:55.0f];
        [_exposeBox setBounds:CGRectMake(0.0f, 0.0f, 110, 110)];
        [_exposeBox setBorderWidth:5.f];
        [_exposeBox setBorderColor:[UIColorFromRGB(0x00ffff, 1) CGColor]];
        [_exposeBox setOpacity:0];
    }
    
    return _exposeBox;
}

- (void) draw:(CALayer *)layer atPointOfInterest:(CGPoint)point andRemove:(BOOL)remove
{
    if ( remove )
        [layer removeAllAnimations];
    
    if ( [layer animationForKey:@"transform.scale"] == nil && [layer animationForKey:@"opacity"] == nil ) {
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
        [layer setPosition:point];
        [CATransaction commit];
        
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [scale setFromValue:[NSNumber numberWithFloat:1]];
        [scale setToValue:[NSNumber numberWithFloat:0.7]];
        [scale setDuration:0.8];
        [scale setRemovedOnCompletion:YES];
        
        CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [opacity setFromValue:[NSNumber numberWithFloat:1]];
        [opacity setToValue:[NSNumber numberWithFloat:0]];
        [opacity setDuration:0.8];
        [opacity setRemovedOnCompletion:YES];
        
        [layer addAnimation:scale forKey:@"transform.scale"];
        [layer addAnimation:opacity forKey:@"opacity"];
    }
}

- (void) drawFocusBoxAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove
{
    [self draw:_focusBox atPointOfInterest:point andRemove:remove];
}

- (void) drawExposeBoxAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove
{
    [self draw:_exposeBox atPointOfInterest:point andRemove:remove];
}

#pragma mark - Gestures

- (void) createGesture
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( tapToFocus: )];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( tapToExpose: )];
    [doubleTap setNumberOfTapsRequired:2];
    [doubleTap setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

#pragma mark - Actions

- (void) tapToFocus:(UIGestureRecognizer *)recognizer
{
    if ( [_delegate respondsToSelector:@selector(cameraView:focusAtPoint:)] )
        [_delegate cameraView:self focusAtPoint:(CGPoint)[recognizer locationInView:self]];
}

- (void) tapToExpose:(UIGestureRecognizer *)recognizer
{
    if ( [_delegate respondsToSelector:@selector(cameraView:exposeAtPoint:)] )
        [_delegate cameraView:self exposeAtPoint:(CGPoint)[recognizer locationInView:self]];
}

@end