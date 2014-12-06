//
//  CustomCamera.m
//  DBCamera
//
//  Created by iBo on 05/02/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "CustomCamera.h"

@interface CustomCamera ()
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) CALayer *focusBox, *exposeBox;
@end

@implementation CustomCamera
@synthesize closeButton = _closeButton;
@synthesize triggerButton = _triggerButton;

- (void) buildInterface
{
    [self addSubview:self.closeButton];
    [self addSubview:self.triggerButton];
    
    [self.previewLayer addSublayer:self.focusBox];
    [self.previewLayer addSublayer:self.exposeBox];
    
    [self createGesture];
}

- (UIButton *) closeButton
{
    if ( !_closeButton ) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setBackgroundColor:[UIColor redColor]];
        [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeButton setFrame:(CGRect){ CGRectGetMidX(self.bounds) - 15, 17.5f, 30, 30 }];
        [_closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _closeButton;
}

- (UIButton *) triggerButton
{
    if ( !_triggerButton ) {
        _triggerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_triggerButton setBackgroundColor:self.tintColor];
        [_triggerButton setImage:[UIImage imageNamed:@"trigger"] forState:UIControlStateNormal];
        [_triggerButton setFrame:(CGRect){ 0, 0, 66, 66 }];
        [_triggerButton.layer setCornerRadius:33.0f];
        [_triggerButton setCenter:(CGPoint){ CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds) - 100 }];
        [_triggerButton addTarget:self action:@selector(triggerAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _triggerButton;
}

- (void) close
{
    if ( [self.delegate respondsToSelector:@selector(closeCamera)] )
        [self.delegate closeCamera];
}

- (void) triggerAction:(UIButton *)button
{
    if ( [self.delegate respondsToSelector:@selector(cameraViewStartRecording)] )
        [self.delegate cameraViewStartRecording];
}

#pragma mark - Focus / Expose Box

- (CALayer *) focusBox
{
    if ( !_focusBox ) {
        _focusBox = [[CALayer alloc] init];
        [_focusBox setCornerRadius:45.0f];
        [_focusBox setBounds:CGRectMake(0.0f, 0.0f, 90, 90)];
        [_focusBox setBorderWidth:5.f];
        [_focusBox setBorderColor:[[UIColor whiteColor] CGColor]];
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
        [_exposeBox setBorderColor:[[UIColor redColor] CGColor]];
        [_exposeBox setOpacity:0];
    }
    
    return _exposeBox;
}

- (void) drawFocusBoxAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove
{
    [super draw:_focusBox atPointOfInterest:point andRemove:remove];
}

- (void) drawExposeBoxAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove
{
    [super draw:_exposeBox atPointOfInterest:point andRemove:remove];
}

#pragma mark - Gestures

- (void) createGesture
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( tapToFocus: )];
    [singleTap setDelaysTouchesEnded:NO];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( tapToExpose: )];
    [doubleTap setDelaysTouchesEnded:NO];
    [doubleTap setNumberOfTapsRequired:2];
    [doubleTap setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void) tapToFocus:(UIGestureRecognizer *)recognizer
{
    CGPoint tempPoint = (CGPoint)[recognizer locationInView:self];
    if ( [self.delegate respondsToSelector:@selector(cameraView:focusAtPoint:)] && CGRectContainsPoint(self.previewLayer.frame, tempPoint) ) {
        [self.delegate cameraView:self focusAtPoint:(CGPoint){ tempPoint.x, tempPoint.y - CGRectGetMinY(self.previewLayer.frame) }];
        [self drawFocusBoxAtPointOfInterest:tempPoint andRemove:YES];
    }
}

- (void) tapToExpose:(UIGestureRecognizer *)recognizer
{
    CGPoint tempPoint = (CGPoint)[recognizer locationInView:self];
    if ( [self.delegate respondsToSelector:@selector(cameraView:exposeAtPoint:)] && CGRectContainsPoint(self.previewLayer.frame, tempPoint) ) {
        [self.delegate cameraView:self exposeAtPoint:(CGPoint){ tempPoint.x, tempPoint.y - CGRectGetMinY(self.previewLayer.frame) }];
        [self drawExposeBoxAtPointOfInterest:tempPoint andRemove:YES];
    }
}

@end
