//
//  DBCameraSegueView.m
//  DBCamera
//
//  Created by iBo on 17/02/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraSegueView.h"
#import "DBCameraImageView.h"

#ifndef DBCameraLocalizedStrings
#define DBCameraLocalizedStrings(key) \
NSLocalizedStringFromTable(key, @"DBCamera", nil)
#endif

#define buttonMargin 20.0f

@implementation DBCameraSegueView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:YES];
        
        _imageView = [[DBCameraImageView alloc] initWithFrame:(CGRect){ 0, 60, CGRectGetWidth([[UIScreen mainScreen] bounds]), CGRectGetHeight([[UIScreen mainScreen] bounds]) - 110 }];
        [_imageView setBackgroundColor:[UIColor clearColor]];
        [_imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:_imageView];
    }
    return self;
}

- (void) buildButtonInterface
{
    [self addSubview:self.stripeView];
    
    [self.retakeButton addTarget:self action:@selector(retakePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.retakeButton];
    
    [self.useButton addTarget:self action:@selector(useImage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.useButton];
    
    [self.cropButton addTarget:self action:@selector(cropQuad:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cropButton];
}

- (UIView *) stripeView
{
    if ( !_stripeView ) {
        _stripeView = [[UIView alloc] initWithFrame:(CGRect){ 0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), 60 }];
        [_stripeView setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:.65f]];
    }
    
    return _stripeView;
}

- (UIButton *) baseButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    return button;
}

- (UIButton *) retakeButton
{
    if ( !_retakeButton ) {
        _retakeButton = [self baseButton];
        [_retakeButton setTitle:DBCameraLocalizedStrings(@"button.retake") forState:UIControlStateNormal];
        [_retakeButton.titleLabel sizeToFit];
        [_retakeButton sizeToFit];
        [_retakeButton setFrame:(CGRect){ 0, 0, CGRectGetWidth(_retakeButton.frame) + buttonMargin, 60 }];
    }
    
    return _retakeButton;
}

- (UIButton *) useButton
{
    if ( !_useButton ) {
        _useButton = [self baseButton];
        [_useButton setTitle:DBCameraLocalizedStrings(@"button.use") forState:UIControlStateNormal];
        [_useButton.titleLabel sizeToFit];
        [_useButton sizeToFit];
        [_useButton setFrame:(CGRect){ CGRectGetWidth(self.frame) - (CGRectGetWidth(_useButton.frame) + buttonMargin), 0, CGRectGetWidth(_useButton.frame) + buttonMargin, 60 }];
    }
    
    return _useButton;
}

- (UIButton *) cropButton
{
    if ( !_cropButton) {
        _cropButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cropButton setBackgroundColor:[UIColor clearColor]];
        [_cropButton setImage:[UIImage imageNamed:@"Crop"] forState:UIControlStateNormal];
        [_cropButton setImage:[UIImage imageNamed:@"CropSelected"] forState:UIControlStateSelected];
        [_cropButton setFrame:(CGRect){ CGRectGetMidX(self.bounds) - 15, 15, 30, 30 }];
    }
    
    return _cropButton;
}

#pragma mark - Methods

- (void) retakePhoto
{
    if ( [_delegate respondsToSelector:@selector(retakeImageFromCameraView:)] )
        [_delegate retakeImageFromCameraView:self];
}

- (void) useImage
{
    if ( [_delegate respondsToSelector:@selector(useImageFromCameraView:)] )
        [_delegate useImageFromCameraView:self];
}

- (void) cropQuad:(UIButton *)button
{
    [button setSelected:!button.isSelected];
    if ( [_delegate respondsToSelector:@selector(cameraView:cropQuadImageForState:)] )
        [_delegate cameraView:self cropQuadImageForState:button.isSelected];
}

@end
