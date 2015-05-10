//
//  CustomCamera.m
//  DBCamera
//
//  Created by iBo on 05/02/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "CustomCamera.h"

@implementation CustomCamera
{
    UIButton *closeButton;
    UIButton *triggerButton;
    
    CALayer *focusBox;
    CALayer *exposeBox;
}

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
    if ( !closeButton ) {
        closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setBackgroundColor:[UIColor redColor]];
        [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [closeButton setFrame:(CGRect){ CGRectGetMidX(self.bounds) - 15, 17.5f, 30, 30 }];
        [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return closeButton;
}

- (UIButton *) triggerButton
{
    if ( !triggerButton ) {
        triggerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [triggerButton setBackgroundColor:self.tintColor];
        [triggerButton setImage:[UIImage imageNamed:@"trigger"] forState:UIControlStateNormal];
        [triggerButton setFrame:(CGRect){ 0, 0, 66, 66 }];
        [triggerButton.layer setCornerRadius:33.0f];
        [triggerButton setCenter:(CGPoint){ CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds) - 100 }];
        [triggerButton addTarget:self action:@selector(triggerAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return triggerButton;
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
    if ( !focusBox ) {
        focusBox = [[CALayer alloc] init];
        [focusBox setCornerRadius:45.0f];
        [focusBox setBounds:CGRectMake(0.0f, 0.0f, 90, 90)];
        [focusBox setBorderWidth:5.f];
        [focusBox setBorderColor:[[UIColor whiteColor] CGColor]];
        [focusBox setOpacity:0];
    }
    
    return focusBox;
}

- (CALayer *) exposeBox
{
    if ( !exposeBox ) {
        exposeBox = [[CALayer alloc] init];
        [exposeBox setCornerRadius:55.0f];
        [exposeBox setBounds:CGRectMake(0.0f, 0.0f, 110, 110)];
        [exposeBox setBorderWidth:5.f];
        [exposeBox setBorderColor:[[UIColor redColor] CGColor]];
        [exposeBox setOpacity:0];
    }
    
    return exposeBox;
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
