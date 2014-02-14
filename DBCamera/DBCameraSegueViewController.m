//
//  DBCameraUseViewController.m
//  DBCamera
//
//  Created by iBo on 11/02/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraSegueViewController.h"
#import "UIImage+Crop.h"

#ifndef DBCameraLocalizedStrings
#define DBCameraLocalizedStrings(key) \
NSLocalizedStringFromTable(key, @"DBCamera", nil)
#endif

#define buttonMargin 20.0f

@interface DBCameraSegueViewController () {
    UIImageView *_imageView;
}

@end

@implementation DBCameraSegueViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
#endif
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    _imageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_imageView setBackgroundColor:[UIColor clearColor]];
    [_imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:_imageView];
    
    UIView *stripe = [[UIView alloc] initWithFrame:(CGRect){ 0, [[UIScreen mainScreen] bounds].size.height - 50, [[UIScreen mainScreen] bounds].size.width, 50 }];
    [stripe setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:.1f]];
    [self.view addSubview:stripe];
    
    UIButton *retakeButton = [self baseButton];
    [retakeButton setTitle:DBCameraLocalizedStrings(@"button.retake") forState:UIControlStateNormal];
    [retakeButton.titleLabel sizeToFit];
    [retakeButton sizeToFit];
    [retakeButton setFrame:(CGRect){ 0, 0, CGRectGetWidth(retakeButton.frame) + buttonMargin, CGRectGetHeight(stripe.frame) }];
    [retakeButton addTarget:self action:@selector(retakePhoto) forControlEvents:UIControlEventTouchUpInside];
    [stripe addSubview:retakeButton];
    
    UIButton *useButton = [self baseButton];
    [useButton setTitle:DBCameraLocalizedStrings(@"button.use") forState:UIControlStateNormal];
    [useButton.titleLabel sizeToFit];
    [useButton sizeToFit];
    [useButton setFrame:(CGRect){ CGRectGetWidth(stripe.frame) - (CGRectGetWidth(useButton.frame) + buttonMargin), 0, CGRectGetWidth(useButton.frame) + buttonMargin, CGRectGetHeight(stripe.frame) }];
    [useButton addTarget:self action:@selector(useImage) forControlEvents:UIControlEventTouchUpInside];
    [stripe addSubview:useButton];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_imageView setImage:self.capturedImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void) setCapturedImage:(UIImage *)capturedImage
{
    _capturedImage = capturedImage;
}

- (void) retakePhoto
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) useImage
{
    if ( [_delegate respondsToSelector:@selector(captureImageDidFinish:)] )
        [_delegate captureImageDidFinish:self.capturedImage];
}

- (void) cropQuadImage
{
    [_imageView setImage:[[UIImage screenshotFromView:self.view] croppedImage:(CGRect){ 0, 248, 640, 640 }]];
}

@end