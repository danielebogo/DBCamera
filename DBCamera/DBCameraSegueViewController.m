//
//  DBCameraSegueViewController.hViewController
//  CropImage
//
//  Created by Daniele Bogo on 19/04/14.
//  Copyright (c) 2014 Daniele Bogo. All rights reserved.
//

#import "DBCameraSegueViewController.h"
#import "DBCameraBaseCropViewController+Private.h"
#import "DBCameraCropView.h"

#ifndef DBCameraLocalizedStrings
#define DBCameraLocalizedStrings(key) \
NSLocalizedStringFromTable(key, @"DBCamera", nil)
#endif

#define buttonMargin 20.0f

@interface DBCameraSegueViewController () {
    DBCameraCropView *_cropView;
    CGRect _pFrame, _lFrame;
}

@property (nonatomic, assign) BOOL cropMode;
@property (nonatomic, strong) UIView *navigationBar;
@property (nonatomic, strong) UIButton *useButton, *retakeButton, *cropButton;
@end

@implementation DBCameraSegueViewController

- (id) initWithImage:(UIImage *)image thumb:(UIImage *)thumb
{
    self = [super init];
    if (self) {
        // Custom initialization
        [self setSourceImage:image];
        [self setPreviewImage:thumb];
        [self setCropRect:(CGRect){ 0, 320 }];
        [self setMinimumScale:.2];
        [self setMaximumScale:10];
        [self createInterface];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
#else
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
#endif
    
    [self.view setUserInteractionEnabled:YES];
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.navigationBar];
    [self.view setClipsToBounds:YES];
    
    _pFrame = (CGRect){ ( CGRectGetWidth( self.frameView.frame) - 320 ) * .5, ( CGRectGetHeight( self.frameView.frame) - 320 ) * .5, 320, 320 };
    _lFrame = (CGRect){ ( CGRectGetWidth( self.frameView.frame) - 320 ) * .5, ( CGRectGetHeight( self.frameView.frame) - 240) * .5, 320, 240 };
    
    [self setCropRect:self.previewImage.size.width > self.previewImage.size.height ? _lFrame : _pFrame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) cropModeAction:(UIButton *)button
{
    [button setSelected:!button.isSelected];
    [self setCropMode:button.isSelected];
    [self setCropRect:button.isSelected ? _pFrame : _lFrame];
    [self reset:YES];
}

- (void) createInterface
{
    CGFloat viewHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]) - 64;
    _cropView = [[DBCameraCropView alloc] initWithFrame:(CGRect){ 0, 64, 320, viewHeight }];
    [_cropView setHidden:YES];
    [self setFrameView:_cropView];
}

- (void) retakeImage
{
    [self.navigationController popViewControllerAnimated:YES];
    [self setSourceImage:nil];
    [self setPreviewImage:nil];
}

- (void) saveImage
{
    if ( [_delegate respondsToSelector:@selector(captureImageDidFinish:withMetadata:)] ) {
        if ( _cropMode )
            [self cropImage];
        else
            [_delegate captureImageDidFinish:self.sourceImage withMetadata:self.capturedImageMetadata];
    }
}

- (void) cropImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGImageRef resultRef = [self newTransformedImage:self.imageView.transform
                                             sourceImage:self.sourceImage.CGImage
                                              sourceSize:self.sourceImage.size
                                       sourceOrientation:self.sourceImage.imageOrientation
                                             outputWidth:self.outputWidth ? self.outputWidth : self.sourceImage.size.width
                                                cropRect:self.cropRect
                                           imageViewSize:self.imageView.bounds.size];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *transform =  [UIImage imageWithCGImage:resultRef scale:1.0 orientation:UIImageOrientationUp];
            CGImageRelease(resultRef);
            [_delegate captureImageDidFinish:transform withMetadata:self.capturedImageMetadata];
        });
    });
}

- (void) setCropMode:(BOOL)cropMode
{
    _cropMode = cropMode;
    [self.frameView setHidden:!_cropMode];
}

- (UIView *) navigationBar
{
    if ( !_navigationBar ) {
        _navigationBar = [[UIView alloc] initWithFrame:(CGRect){ 0, 0, 320, 64 }];
        [_navigationBar setBackgroundColor:[UIColor blackColor]];
        [_navigationBar setUserInteractionEnabled:YES];
        [_navigationBar addSubview:self.useButton];
        [_navigationBar addSubview:self.retakeButton];
        [_navigationBar addSubview:self.cropButton];
    }
    
    return _navigationBar;
}

- (UIButton *) useButton
{
    if ( !_useButton ) {
        _useButton = [self baseButton];
        [_useButton setTitle:DBCameraLocalizedStrings(@"button.use") forState:UIControlStateNormal];
        [_useButton.titleLabel sizeToFit];
        [_useButton sizeToFit];
        [_useButton setFrame:(CGRect){ CGRectGetWidth(self.view.frame) - (CGRectGetWidth(_useButton.frame) + buttonMargin), 0, CGRectGetWidth(_useButton.frame) + buttonMargin, 60 }];
        [_useButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _useButton;
}

- (UIButton *) retakeButton
{
    if ( !_retakeButton ) {
        _retakeButton = [self baseButton];
        [_retakeButton setTitle:DBCameraLocalizedStrings(@"button.retake") forState:UIControlStateNormal];
        [_retakeButton.titleLabel sizeToFit];
        [_retakeButton sizeToFit];
        [_retakeButton setFrame:(CGRect){ 0, 0, CGRectGetWidth(_retakeButton.frame) + buttonMargin, 60 }];
        [_retakeButton addTarget:self action:@selector(retakeImage) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _retakeButton;
}

- (UIButton *) cropButton
{
    if ( !_cropButton) {
        _cropButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cropButton setBackgroundColor:[UIColor clearColor]];
        [_cropButton setImage:[UIImage imageNamed:@"Crop"] forState:UIControlStateNormal];
        [_cropButton setImage:[UIImage imageNamed:@"CropSelected"] forState:UIControlStateSelected];
        [_cropButton setFrame:(CGRect){ CGRectGetMidX(self.view.bounds) - 15, 15, 30, 30 }];
        [_cropButton addTarget:self action:@selector(cropModeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cropButton;
}

- (UIButton *) baseButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    return button;
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

@end