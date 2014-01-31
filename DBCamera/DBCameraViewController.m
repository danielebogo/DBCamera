//
//  DBCameraViewController.m
//  DBCamera
//
//  Created by iBo on 31/01/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraViewController.h"
#import "DBCameraManager.h"
#import "DBCameraView.h"

#import <AVFoundation/AVFoundation.h>

@interface DBCameraViewController () <DBCameraManagerDelegate, DBCameraViewDelegate> {
    BOOL _processingPhoto;
}

@property (nonatomic, strong) DBCameraView *cameraView;
@property (nonatomic, strong) DBCameraManager *cameraManager;

@end

@implementation DBCameraViewController

- (id) init
{
    self = [super init];
    
    if ( self ) {
        _processingPhoto = NO;
    }
    
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    NSError *error;
    if ( [self.cameraManager setupSessionWithPreset:AVCaptureSessionPresetPhoto error:&error] ) {
        _cameraView = [[DBCameraView alloc] initWithCaptureSession:self.cameraManager.captureSession];
        [_cameraView setDelegate:self];
        [self.view addSubview:_cameraView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.cameraManager performSelector:@selector(startRunning) withObject:nil afterDelay:0.0];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    _previewLayer.hidden = YES;
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.cameraManager performSelector:@selector(stopRunning) withObject:nil afterDelay:0.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setCameraManager:nil];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (DBCameraManager *) cameraManager
{
    if ( !_cameraManager ) {
        _cameraManager = [[DBCameraManager alloc] init];
        [_cameraManager setDelegate:self];
    }
    
    return _cameraManager;
}

#pragma mark - CameraManagerDelagate

- (void) captureImageDidFinish:(UIImage *)image
{
    _processingPhoto = NO;
    
}

- (void) captureImageFailedWithError:(NSError *)error
{
    
}

- (void) captureSessionDidStartRunning
{
    CGRect bounds = _cameraView.bounds;
    CGPoint screenCenter = (CGPoint){ bounds.size.width / 2.0f, bounds.size.height / 2.0f };
    [_cameraView drawFocusBoxAtPointOfInterest:screenCenter andRemove:NO];
    [_cameraView drawExposeBoxAtPointOfInterest:screenCenter andRemove:NO];
}

#pragma mark - CameraViewDelegate

- (void) cameraViewStartRecording
{
    if ( _processingPhoto )
        return;
    
    _processingPhoto = YES;
    
    [self.cameraManager captureImage];
}

- (void) cameraView:(DBCameraView *)camera focusAtPoint:(CGPoint)point
{
    if ( self.cameraManager.videoInput.device.isFocusPointOfInterestSupported ) {
        [self.cameraManager focusAtPoint:[self.cameraManager convertToPointOfInterestFrom:camera.frame
                                                                              coordinates:point
                                                                                    layer:camera.previewLayer]];
        [camera drawFocusBoxAtPointOfInterest:point andRemove:YES];
    }
}

- (void) cameraView:(DBCameraView *)camera exposeAtPoint:(CGPoint)point
{
    if ( self.cameraManager.videoInput.device.isExposurePointOfInterestSupported ) {
        [self.cameraManager exposureAtPoint:[self.cameraManager convertToPointOfInterestFrom:camera.frame
                                                                                 coordinates:point
                                                                                       layer:camera.previewLayer]];
        [camera drawExposeBoxAtPointOfInterest:point andRemove:YES];
    }
}

#pragma mark - UIApplicationDidEnterBackgroundNotification

- (void) applicationDidEnterBackground:(NSNotification *)notification
{
    id modalViewController = self.presentingViewController;
    if ( modalViewController )
        [self dismissViewControllerAnimated:YES completion:nil];
}

@end