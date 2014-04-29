//
//  DBCameraView.m
//  DBCamera
//
//  Created by iBo on 31/01/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraView.h"
#import "DBCameraMacros.h"
#import "UIImage+Crop.h"

#import <AssetsLibrary/AssetsLibrary.h>


#define previewFrameRetina (CGRect){ 0, 65, 320, 342 }
#define previewFrameRetina_4 (CGRect){ 0, 65, 320, 430 }

// pinch
#define MAX_PINCH_SCALE_NUM   3.f
#define MIN_PINCH_SCALE_NUM   1.f

@interface DBCameraView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) CALayer *focusBox, *exposeBox;
@property (nonatomic, strong) UIView *topContainerBar;
@property (nonatomic, strong) UIView *bottomContainerBar;

// pinch
@property (nonatomic, assign) CGFloat preScaleNum;
@property (nonatomic, assign) CGFloat scaleNum;
@end

@implementation DBCameraView

+ (id) initWithFrame:(CGRect)frame
{
    return [[self alloc] initWithFrame:frame captureSession:nil];
}

+ (DBCameraView *) initWithCaptureSession:(AVCaptureSession *)captureSession
{
    return [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds] captureSession:captureSession];
}

- (id) initWithFrame:(CGRect)frame captureSession:(AVCaptureSession *)captureSession
{
    self = [super initWithFrame:frame];
    
    if ( self ) {
        [self setBackgroundColor:[UIColor blackColor]];
        
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
        if ( captureSession ) {
            [_previewLayer setSession:captureSession];
            [_previewLayer setFrame: IS_RETINA_4 ? previewFrameRetina_4 : previewFrameRetina ];
        } else
            [_previewLayer setFrame:self.bounds];
        
        if ( [_previewLayer respondsToSelector:@selector(connection)] ) {
            if ( [_previewLayer.connection isVideoOrientationSupported] )
                [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        }
        
        [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        [self.layer addSublayer:_previewLayer];
    }
    
    return self;
}

- (void) defaultInterface
{
    [_previewLayer addSublayer:self.focusBox];
    [_previewLayer addSublayer:self.exposeBox];
    
    [self addSubview:self.topContainerBar];
    [self addSubview:self.bottomContainerBar];
    
    [self.topContainerBar addSubview:self.cameraButton];
    [self.topContainerBar addSubview:self.flashButton];
    [self.topContainerBar addSubview:self.gridButton];
    
    [self.bottomContainerBar addSubview:self.triggerButton];
    [self.bottomContainerBar addSubview:self.closeButton];
    [self.bottomContainerBar addSubview:self.photoLibraryButton];
    
    [self createGesture];
}

#pragma mark - Containers

- (UIView *) topContainerBar
{
    if ( !_topContainerBar ) {
        _topContainerBar = [[UIView alloc] initWithFrame:(CGRect){ 0, 0, CGRectGetWidth(self.bounds), CGRectGetMinY(IS_RETINA_4 ? previewFrameRetina_4 : previewFrameRetina) }];
        _topContainerBar.backgroundColor = [UIColor blackColor];
    }
    return _topContainerBar;
}

- (UIView *) bottomContainerBar
{
    if ( !_bottomContainerBar ) {
        CGFloat newY = CGRectGetMaxY( IS_RETINA_4 ? previewFrameRetina_4 : previewFrameRetina );
        _bottomContainerBar = [[UIView alloc] initWithFrame:(CGRect){ 0, newY, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - newY }];
        [_bottomContainerBar setUserInteractionEnabled:YES];
        [_bottomContainerBar setBackgroundColor:RGBColor(0x000000, 1)];
    }
    return _bottomContainerBar;
}

#pragma mark - Buttons

- (UIButton *) photoLibraryButton
{
    if ( !_photoLibraryButton ) {
        _photoLibraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_photoLibraryButton setBackgroundColor:RGBColor(0xffffff, .1)];
        [_photoLibraryButton.layer setCornerRadius:4];
        [_photoLibraryButton.layer setBorderWidth:1];
        [_photoLibraryButton.layer setBorderColor:RGBColor(0xffffff, .3).CGColor];
        [_photoLibraryButton setFrame:(CGRect){ CGRectGetWidth(self.bounds) - 59, CGRectGetMidY(self.bottomContainerBar.bounds) - 22, 44, 44 }];
        [_photoLibraryButton addTarget:self action:@selector(libraryAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _photoLibraryButton;
}

- (UIButton *) triggerButton
{
    if ( !_triggerButton ) {
        _triggerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_triggerButton setBackgroundColor:[UIColor whiteColor]];
        [_triggerButton setImage:[UIImage imageNamed:@"trigger"] forState:UIControlStateNormal];
        [_triggerButton setFrame:(CGRect){ 0, 0, 66, 66 }];
        [_triggerButton.layer setCornerRadius:33.0f];
        [_triggerButton setCenter:(CGPoint){ CGRectGetMidX(self.bottomContainerBar.bounds), CGRectGetMidY(self.bottomContainerBar.bounds) }];
        [_triggerButton addTarget:self action:@selector(triggerAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _triggerButton;
}

- (UIButton *) closeButton
{
    if ( !_closeButton ) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setBackgroundColor:[UIColor clearColor]];
        [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeButton setFrame:(CGRect){ 25,  CGRectGetMidY(self.bottomContainerBar.bounds) - 15, 30, 30 }];
        [_closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _closeButton;
}

- (UIButton *) cameraButton
{
    if ( !_cameraButton ) {
        _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraButton setBackgroundColor:[UIColor clearColor]];
        [_cameraButton setImage:[UIImage imageNamed:@"flip"] forState:UIControlStateNormal];
        [_cameraButton setImage:[UIImage imageNamed:@"flipSelected"] forState:UIControlStateSelected];
        [_cameraButton setFrame:(CGRect){ 25, 17.5f, 30, 30 }];
        [_cameraButton addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cameraButton;
}

- (UIButton *) flashButton
{
    if ( !_flashButton ) {
        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashButton setBackgroundColor:[UIColor clearColor]];
        [_flashButton setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
        [_flashButton setImage:[UIImage imageNamed:@"flashSelected"] forState:UIControlStateSelected];
        [_flashButton setFrame:(CGRect){ CGRectGetWidth(self.bounds) - 55, 17.5f, 30, 30 }];
        [_flashButton addTarget:self action:@selector(flashTriggerAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _flashButton;
}

- (UIButton *) gridButton
{
    if ( !_gridButton ) {
        _gridButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_gridButton setBackgroundColor:[UIColor clearColor]];
        [_gridButton setImage:[UIImage imageNamed:@"cameraGridNormal"] forState:UIControlStateNormal];
        [_gridButton setImage:[UIImage imageNamed:@"cameraGridSelected"] forState:UIControlStateSelected];
        [_gridButton setFrame:(CGRect){ 0, 0, 30, 30 }];
        [_gridButton setCenter:(CGPoint){ CGRectGetMidX(self.topContainerBar.bounds), CGRectGetMidY(self.topContainerBar.bounds) }];
        [_gridButton addTarget:self action:@selector(addGridToCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _gridButton;
}

#pragma mark - Focus / Expose Box

- (CALayer *) focusBox
{
    if ( !_focusBox ) {
        _focusBox = [[CALayer alloc] init];
        [_focusBox setCornerRadius:45.0f];
        [_focusBox setBounds:CGRectMake(0.0f, 0.0f, 90, 90)];
        [_focusBox setBorderWidth:5.f];
        [_focusBox setBorderColor:[RGBColor(0xffffff, 1) CGColor]];
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
        [_exposeBox setBorderColor:[RGBColor(0x00ffff, 1) CGColor]];
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
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( tapToFocus: )];
    [_singleTap setDelaysTouchesEnded:NO];
    [_singleTap setNumberOfTapsRequired:1];
    [_singleTap setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:_singleTap];
    
    _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( tapToExpose: )];
    [_doubleTap setDelaysTouchesEnded:NO];
    [_doubleTap setNumberOfTapsRequired:2];
    [_doubleTap setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:_doubleTap];
    
    [_singleTap requireGestureRecognizerToFail:_doubleTap];
    
    _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [_pinch setDelaysTouchesEnded:NO];
    [self addGestureRecognizer:_pinch];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector( hanldePanGestureRecognizer: )];
    [_panGestureRecognizer setDelaysTouchesEnded:NO];
    [_panGestureRecognizer setMinimumNumberOfTouches:1];
    [_panGestureRecognizer setMaximumNumberOfTouches:1];
    [_panGestureRecognizer setDelegate:self];
    [self addGestureRecognizer:_panGestureRecognizer];
}

#pragma mark - Actions

- (void) libraryAction:(UIButton *)button
{
    if ( [_delegate respondsToSelector:@selector(openLibrary)] )
        [_delegate openLibrary];
}

- (void) addGridToCameraAction:(UIButton *)button
{
    if ( [_delegate respondsToSelector:@selector(cameraView:showGridView:)] ) {
        [_delegate cameraView:self showGridView:button.selected];
        [button setSelected:!button.isSelected];
    }
}

- (void) flashTriggerAction:(UIButton *)button
{
    if ( [_delegate respondsToSelector:@selector(triggerFlashForMode:)] ) {
        [button setSelected:!button.isSelected];
        [_delegate triggerFlashForMode: button.isSelected ? AVCaptureFlashModeOn : AVCaptureFlashModeOff ];
    }
}

- (void) changeCamera:(UIButton *)button
{
    [button setSelected:!button.isSelected];
    if ( button.isSelected && self.flashButton.isSelected )
        [self flashTriggerAction:self.flashButton];
    [self.flashButton setEnabled:!button.isSelected];
    if ( [self.delegate respondsToSelector:@selector(switchCamera)] )
        [self.delegate switchCamera];
}

- (void) close
{
    if ( [_delegate respondsToSelector:@selector(closeCamera)] )
        [_delegate closeCamera];
}

- (void) triggerAction:(UIButton *)button
{
    if ( [_delegate respondsToSelector:@selector(cameraViewStartRecording)] )
        [_delegate cameraViewStartRecording];
}

- (void) tapToFocus:(UIGestureRecognizer *)recognizer
{
    CGPoint tempPoint = (CGPoint)[recognizer locationInView:self];
    if ( [_delegate respondsToSelector:@selector(cameraView:focusAtPoint:)] && CGRectContainsPoint(_previewLayer.frame, tempPoint) )
        [_delegate cameraView:self focusAtPoint:(CGPoint){ tempPoint.x, tempPoint.y - CGRectGetMinY(_previewLayer.frame) }];
}

- (void) tapToExpose:(UIGestureRecognizer *)recognizer
{
    CGPoint tempPoint = (CGPoint)[recognizer locationInView:self];
    if ( [_delegate respondsToSelector:@selector(cameraView:exposeAtPoint:)] && CGRectContainsPoint(_previewLayer.frame, tempPoint) )
        [_delegate cameraView:self exposeAtPoint:(CGPoint){ tempPoint.x, tempPoint.y - CGRectGetMinY(_previewLayer.frame) }];
}

- (void) hanldePanGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
{
    BOOL hasFocus = YES;
    if ( [_delegate respondsToSelector:@selector(cameraViewHasFocus)] )
        hasFocus = [_delegate cameraViewHasFocus];

    if ( !hasFocus )
        return;
    
    UIGestureRecognizerState state = panGestureRecognizer.state;
    CGPoint touchPoint = [panGestureRecognizer locationInView:self];
    [self draw:_focusBox atPointOfInterest:(CGPoint){ touchPoint.x, touchPoint.y - CGRectGetMinY(_previewLayer.frame) } andRemove:YES];
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
            
            break;
        case UIGestureRecognizerStateChanged: {
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded: {
            [self tapToFocus:panGestureRecognizer];
            break;
        }
        default:
            break;
    }
}

- (void) handlePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    BOOL allTouchesAreOnThePreviewLayer = YES;
	NSUInteger numTouches = [pinchGestureRecognizer numberOfTouches], i;
	for ( i = 0; i < numTouches; ++i ) {
		CGPoint location = [pinchGestureRecognizer locationOfTouch:i inView:self];
		CGPoint convertedLocation = [_previewLayer convertPoint:location fromLayer:_previewLayer.superlayer];
		if ( ! [_previewLayer containsPoint:convertedLocation] ) {
			allTouchesAreOnThePreviewLayer = NO;
			break;
		}
	}
	
	if ( allTouchesAreOnThePreviewLayer ) {
		_scaleNum = _preScaleNum * pinchGestureRecognizer.scale;
        
        if ( _scaleNum < MIN_PINCH_SCALE_NUM )
            _scaleNum = MIN_PINCH_SCALE_NUM;
        else if ( _scaleNum > MAX_PINCH_SCALE_NUM )
            _scaleNum = MAX_PINCH_SCALE_NUM;
        
        if ( [self.delegate respondsToSelector:@selector(cameraCaptureScale:)] )
            [self.delegate cameraCaptureScale:_scaleNum];
        
        [self doPinch];
	}
    
    if ( [pinchGestureRecognizer state] == UIGestureRecognizerStateEnded ||
         [pinchGestureRecognizer state] == UIGestureRecognizerStateCancelled ||
         [pinchGestureRecognizer state] == UIGestureRecognizerStateFailed) {
         _preScaleNum = _scaleNum;
    }
}

- (void) pinchCameraViewWithScalNum:(CGFloat)scale
{
    _scaleNum = scale;
    if ( _scaleNum < MIN_PINCH_SCALE_NUM )
        _scaleNum = MIN_PINCH_SCALE_NUM;
    else if (_scaleNum > MAX_PINCH_SCALE_NUM)
        _scaleNum = MAX_PINCH_SCALE_NUM;

    [self doPinch];
    _preScaleNum = scale;
}

- (void) doPinch
{
    if ( [self.delegate respondsToSelector:@selector(cameraMaxScale)] ) {
        CGFloat maxScale = [self.delegate cameraMaxScale];
        if ( _scaleNum > maxScale )
            _scaleNum = maxScale;
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [_previewLayer setAffineTransform:CGAffineTransformMakeScale(_scaleNum, _scaleNum)];
        [CATransaction commit];
    }
}

@end