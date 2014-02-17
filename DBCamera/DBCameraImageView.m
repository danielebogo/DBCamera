//
//  DBCameraImageVIew.m
//  DBCamera
//
//  Created by iBo on 17/02/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraImageView.h"

#define SIZE_LIMIT 320

@interface DBCameraImageView () <UIGestureRecognizerDelegate> {
    CGFloat _tx;
	CGFloat _ty;
	CGFloat _scale;
    
    CGFloat _lastScale;
    
	CGFloat _firstX;
	CGFloat _firstY;
}

@end

@implementation DBCameraImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUserInteractionEnabled:YES];
        
        self.transform = CGAffineTransformIdentity;
        
        _tx = 0.0f;
        _ty = 0.0f;
        _scale = 1.0f;
        _lastScale = 1.0f;
        
        [self setGesturesEnabled:NO];
        
        // Add gesture recognizer suite
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.gestureRecognizers = @[  pinch, pan ];
        for (UIGestureRecognizer *recognizer in self.gestureRecognizers)
            recognizer.delegate = self;
    }
    return self;
}

- (void) resetPosition
{
    _tx = 0.0f;
    _ty = 0.0f;
    _scale = 1.0f;
    
    self.layer.anchorPoint = (CGPoint){ .5, .5 };
    self.center = self.defaultCenter;
    
    self.transform = CGAffineTransformMakeTranslation(0, 0);
    self.transform = CGAffineTransformRotate(self.transform, 0);
    self.transform = CGAffineTransformScale(self.transform, 1, 1);
}

- (void) handlePinch:(UIPinchGestureRecognizer *)gesture
{
    if ( !self.isGesturesEnabled )
        return;
    
    if( gesture.state == UIGestureRecognizerStateEnded ) {
		_lastScale = 1.0f;
//        if ( CGRectGetWidth(self.frame) < SIZE_LIMIT || CGRectGetHeight(self.frame) < SIZE_LIMIT )
//            [self resetPosition];
		return;
	}
    
	_scale = 1.0f - (_lastScale - [gesture scale]);
    
	CGAffineTransform currentTransform = self.transform;
	CGAffineTransform newTransform = CGAffineTransformScale( currentTransform, _scale, _scale );
    
	[self setTransform:newTransform];
    
	_lastScale = [gesture scale];
}

- (void) handlePan:(UIPanGestureRecognizer *)gesture
{
	if ( !self.isGesturesEnabled )
        return;
    
    UIView *piece = [gesture view];
    [self adjustAnchorPointForGestureRecognizer:gesture];
    
    if ( gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged ) {
        CGPoint translation = [gesture translationInView:piece.superview];
        [piece setCenter:(CGPoint){ piece.center.x + translation.x, piece.center.y + translation.y }];
        [gesture setTranslation:CGPointZero inView:piece.superview];
    }
    
}

- (void) adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if ( gestureRecognizer.state == UIGestureRecognizerStateBegan ) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = (CGPoint){ locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height };
        piece.center = locationInSuperview;
    }
}

#pragma mark - Gesture Delegate

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

#pragma mark - Touch Events

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//	[self.superview bringSubviewToFront:self];
    
	_tx = self.transform.tx;
	_ty = self.transform.ty;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	if ( touch.tapCount == 2 )
		[self resetPosition];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

@end
