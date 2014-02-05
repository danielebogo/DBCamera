//
//  RootViewController.m
//  DBCamera
//
//  Created by iBo on 31/01/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "RootViewController.h"
#import "DBCameraViewController.h"
#import "CustomCamera.h"

@interface RootViewController () <DBCameraViewControllerDelegate> {
    UIImageView *_imageView;
}
@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    [self.navigationItem setTitle:@"Root"];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Custom Camera" style:UIBarButtonItemStylePlain target:self action:@selector(openCustomCamera:)]];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Open Camera" style:UIBarButtonItemStylePlain target:self action:@selector(openCamera:)]];
    
    _imageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:_imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) openCamera:(id)sender
{
    [self presentViewController:[DBCameraViewController initWithDelegate:self] animated:YES completion:nil];
}

- (void) openCustomCamera:(id)sender
{
    CustomCamera *camera = [CustomCamera initWithFrame:[[UIScreen mainScreen] bounds]];
    [camera buildIntarface];
    
    [self presentViewController:[[DBCameraViewController alloc] initWithDelegate:self cameraView:camera]
                       animated:YES completion:nil];
}

#pragma mrak - DBCameraViewControllerDelegate

- (void) captureImageDidFinish:(UIImage *)image
{
    [_imageView setImage:image];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end