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
#import "DBCameraViewDelegate.h"

#import <AVFoundation/AVFoundation.h>

@interface DBCameraViewController () <DBCameraManagerDelegate, DBCameraViewDelegate> {
    BOOL _processingPhoto;
    UIDeviceOrientation _deviceOrientation;
}

@property (nonatomic, strong) DBCameraView *cameraView, *customCamera;
@property (nonatomic, strong) DBCameraManager *cameraManager;

@end

@implementation DBCameraViewController

+ (DBCameraViewController *) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate
{
    return [[self alloc] initWithDelegate:delegate cameraView:nil];
}

+ (DBCameraViewController *) init
{
    return [[self alloc] initWithDelegate:nil cameraView:nil];
}

- (id) initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate cameraView:(id)camera
{
    self = [super init];
    
    if ( self ) {
        _processingPhoto = NO;
        _deviceOrientation = UIDeviceOrientationPortrait;
        if ( delegate )
            _delegate = delegate;
        
        if ( camera )
            [self setCustomCamera:camera];
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
        if ( self.customCamera ) {
            [self.customCamera.previewLayer setSession:self.cameraManager.captureSession];
            if ( !self.customCamera.delegate )
                [self.customCamera setDelegate:self];
            [self.view addSubview:self.customCamera];
        } else
            [self.view addSubview:self.cameraView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.cameraManager performSelector:@selector(startRunning) withObject:nil afterDelay:0.0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rotationChanged:)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.cameraManager performSelector:@selector(stopRunning) withObject:nil afterDelay:0.0];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
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

- (DBCameraView *) cameraView
{
    if ( !_cameraView ) {
        _cameraView = [DBCameraView initWithCaptureSession:self.cameraManager.captureSession];
        [_cameraView defaultInterface];
        [_cameraView setDelegate:self];
    }
    
    return _cameraView;
}

- (DBCameraManager *) cameraManager
{
    if ( !_cameraManager ) {
        _cameraManager = [[DBCameraManager alloc] init];
        [_cameraManager setDelegate:self];
    }
    
    return _cameraManager;
}

- (void) rotationChanged:(NSNotification *)notification
{
    if ( [[UIDevice currentDevice] orientation] != UIDeviceOrientationUnknown ||
         [[UIDevice currentDevice] orientation] != UIDeviceOrientationFaceUp ||
         [[UIDevice currentDevice] orientation] != UIDeviceOrientationFaceDown ) {
        _deviceOrientation = [[UIDevice currentDevice] orientation];
    }
}

#pragma mark - CameraManagerDelagate

- (void) closeCamera
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) switchCamera
{
    if ( [self.cameraManager hasMultipleCameras] )
        [self.cameraManager cameraToggle];
}

- (void) triggerFlashForMode:(AVCaptureFlashMode)flashMode
{
    if ( [self.cameraManager hasFlash] )
        [self.cameraManager setFlashMode:flashMode];
}

- (void) captureImageDidFinish:(UIImage *)image
{
    _processingPhoto = NO;
    
    if ( [_delegate respondsToSelector:@selector(captureImageDidFinish:)] )
        [_delegate captureImageDidFinish:image];
}

- (void) captureImageFailedWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    });
}

- (void) captureSessionDidStartRunning
{
    CGRect bounds = _cameraView.bounds;
    CGPoint screenCenter = (CGPoint){ (bounds.size.width * .5f), (bounds.size.height * .5f) - CGRectGetMinY(_cameraView.previewLayer.frame) };
    [_cameraView drawFocusBoxAtPointOfInterest:screenCenter andRemove:NO];
    [_cameraView drawExposeBoxAtPointOfInterest:screenCenter andRemove:NO];
}

#pragma mark - CameraViewDelegate

- (void) cameraViewStartRecording
{
    if ( _processingPhoto )
        return;
    
    _processingPhoto = YES;
    
    [self.cameraManager captureImageForDeviceOrientation:_deviceOrientation];
}

- (void) cameraView:(UIView *)camera focusAtPoint:(CGPoint)point
{
    if ( self.cameraManager.videoInput.device.isFocusPointOfInterestSupported ) {
        [self.cameraManager focusAtPoint:[self.cameraManager convertToPointOfInterestFrom:[[(DBCameraView *)camera previewLayer] frame]
                                                                              coordinates:point
                                                                                    layer:[(DBCameraView *)camera previewLayer]]];
        [(DBCameraView *)camera drawFocusBoxAtPointOfInterest:point andRemove:YES];
    }
}

- (void) cameraView:(UIView *)camera exposeAtPoint:(CGPoint)point
{
    if ( self.cameraManager.videoInput.device.isExposurePointOfInterestSupported ) {
        [self.cameraManager exposureAtPoint:[self.cameraManager convertToPointOfInterestFrom:[[(DBCameraView *)camera previewLayer] frame]
                                                                                 coordinates:point
                                                                                       layer:[(DBCameraView *)camera previewLayer]]];
        [(DBCameraView *)camera drawExposeBoxAtPointOfInterest:point andRemove:YES];
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