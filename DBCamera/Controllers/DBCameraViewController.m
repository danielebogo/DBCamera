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
#import "DBCameraGridView.h"
#import "DBCameraDelegate.h"
#import "DBCameraSegueViewController.h"
#import "DBCameraLibraryViewController.h"
#import "DBLibraryManager.h"

#import "UIImage+Crop.h"
#import "DBCameraMacros.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MotionOrientation.h"

#ifndef DBCameraLocalizedStrings
#define DBCameraLocalizedStrings(key)                                          \
  NSLocalizedStringFromTable(key, @"DBCamera", nil)
#endif

@interface DBCameraViewController () <DBCameraManagerDelegate,
                                      DBCameraViewDelegate> {
  BOOL _processingPhoto;
  UIDeviceOrientation _deviceOrientation;
  BOOL wasStatusBarHidden;
  BOOL wasWantsFullScreenLayout;
}

@property(nonatomic, strong) id customCamera;
@property(nonatomic, strong) DBCameraManager *cameraManager;
@end

@implementation DBCameraViewController
@synthesize cameraGridView = _cameraGridView;
@synthesize forceQuadCrop = _forceQuadCrop;
@synthesize tintColor = _tintColor;
@synthesize selectedTintColor = _selectedTintColor;
@synthesize cameraSegueConfigureBlock = _cameraSegueConfigureBlock;

#pragma mark - Life cycle

+ (DBCameraViewController *)initWithDelegate:
                                (id<DBCameraViewControllerDelegate>)delegate {
  return [[self alloc] initWithDelegate:delegate cameraView:nil];
}

+ (DBCameraViewController *)init {
  return [[self alloc] initWithDelegate:nil cameraView:nil];
}

- (id)initWithDelegate:(id<DBCameraViewControllerDelegate>)delegate
            cameraView:(id)camera {
  self = [super init];

  if (self) {
    _processingPhoto = NO;
    _deviceOrientation = UIDeviceOrientationPortrait;
    if (delegate)
      _delegate = delegate;

    if (camera)
      [self setCustomCamera:camera];

    [self setUseCameraSegue:YES];

    [self setTintColor:[UIColor whiteColor]];
    [self setSelectedTintColor:[UIColor cyanColor]];
  }

  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  [self.view setBackgroundColor:[UIColor blackColor]];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(applicationDidEnterBackground:)
             name:UIApplicationDidEnterBackgroundNotification
           object:nil];

  NSError *error;
  if ([self.cameraManager setupSessionWithPreset:AVCaptureSessionPresetPhoto
                                           error:&error]) {
    if (self.customCamera) {
      if ([self.customCamera respondsToSelector:@selector(previewLayer)]) {
        [(AVCaptureVideoPreviewLayer *)
            [self.customCamera valueForKey:@"previewLayer"]
            setSession:self.cameraManager.captureSession];

        if ([self.customCamera respondsToSelector:@selector(delegate)])
          [self.customCamera setValue:self forKey:@"delegate"];
      }

      [self.view addSubview:self.customCamera];
    } else
      [self.view addSubview:self.cameraView];
  }

  id camera = _customCamera ?: _cameraView;
  [camera insertSubview:self.cameraGridView atIndex:1];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.cameraManager performSelector:@selector(startRunning)
                           withObject:nil
                           afterDelay:0.0];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(motionOrientationChanged:)
             name:MotionOrientationChangedNotification
           object:nil];
  [MotionOrientation initialize];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if (!self.customCamera)
    [self checkForLibraryImage];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.cameraManager performSelector:@selector(stopRunning)
                           withObject:nil
                           afterDelay:0.0];

  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:MotionOrientationChangedNotification
              object:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self setCameraManager:nil];
}

- (void)checkForLibraryImage {
  if (!self.cameraView.photoLibraryButton.isHidden &&
      [NSStringFromClass(self.parentViewController.class)
          isEqualToString:@"DBCameraContainerViewController"]) {
    if ([ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusDenied) {
      __weak DBCameraView *weakCamera = self.cameraView;
      [[DBLibraryManager sharedInstance]
          loadLastItemWithBlock:^(BOOL success, UIImage *image) {
              [weakCamera.photoLibraryButton
                  setBackgroundImage:image
                            forState:UIControlStateNormal];
          }];
    }
  } else
    [self.cameraView.photoLibraryButton setHidden:YES];
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

- (void)dismissCamera {
  if (_delegate && [_delegate respondsToSelector:@selector(dismissCamera:)])
    [_delegate dismissCamera:self];
}

- (DBCameraView *)cameraView {
  if (!_cameraView) {
    _cameraView =
        [DBCameraView initWithCaptureSession:self.cameraManager.captureSession];
    [_cameraView setTintColor:self.tintColor];
    [_cameraView setSelectedTintColor:self.selectedTintColor];
    [_cameraView defaultInterface];
    [_cameraView setDelegate:self];
  }

  return _cameraView;
}

- (DBCameraManager *)cameraManager {
  if (!_cameraManager) {
    _cameraManager = [[DBCameraManager alloc] init];
    [_cameraManager setDelegate:self];
  }

  return _cameraManager;
}

- (DBCameraGridView *)cameraGridView {
  if (!_cameraGridView) {
    DBCameraView *camera = _customCamera ?: _cameraView;
    _cameraGridView =
        [[DBCameraGridView alloc] initWithFrame:camera.previewLayer.frame];
    [_cameraGridView setNumberOfColumns:2];
    [_cameraGridView setNumberOfRows:2];
    [_cameraGridView setAlpha:0];
  }

  return _cameraGridView;
}

- (void)setCameraGridView:(DBCameraGridView *)cameraGridView {
  _cameraGridView = cameraGridView;
  __block DBCameraGridView *blockGridView = cameraGridView;
  __weak DBCameraView *camera = _customCamera ?: _cameraView;
  [camera.subviews
      enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
          if ([obj isKindOfClass:[DBCameraGridView class]]) {
            [obj removeFromSuperview];
            [camera insertSubview:blockGridView atIndex:1];
            blockGridView = nil;
            *stop = YES;
          }
      }];
}

- (void)motionOrientationChanged:(NSNotification *)notification {
  if ([MotionOrientation sharedInstance].deviceOrientation !=
          UIDeviceOrientationUnknown ||
      [MotionOrientation sharedInstance].deviceOrientation !=
          UIDeviceOrientationFaceUp ||
      [MotionOrientation sharedInstance].deviceOrientation !=
          UIDeviceOrientationFaceDown) {
    _deviceOrientation = [MotionOrientation sharedInstance].deviceOrientation;
  }
}

- (void)disPlayGridViewToCameraView:(BOOL)show {
  [UIView
      animateWithDuration:0.3
                    delay:0
                  options:UIViewAnimationOptionCurveEaseInOut
               animations:^{ self.cameraGridView.alpha = (show ? 1.0 : 0.0); }
               completion:NULL];
}

#pragma mark - CameraManagerDelagate

- (void)closeCamera {
  [self dismissCamera];
}

- (void)switchCamera {
  if ([self.cameraManager hasMultipleCameras])
    [self.cameraManager cameraToggle];
}

- (void)cameraView:(UIView *)camera showGridView:(BOOL)show {
  [self disPlayGridViewToCameraView:!show];
}

- (void)triggerFlashForMode:(AVCaptureFlashMode)flashMode {
  if ([self.cameraManager hasFlash])
    [self.cameraManager setFlashMode:flashMode];
}

- (void)captureImageDidFinish:(UIImage *)image
                 withMetadata:(NSDictionary *)metadata {

  _processingPhoto = NO;
  NSMutableDictionary *finalMetadata =
      [NSMutableDictionary dictionaryWithDictionary:metadata];
  finalMetadata[@"DBCameraSource"] = @"Camera";

  if (!self.useCameraSegue) {
    if ([_delegate respondsToSelector:@selector(camera:
                                          didFinishWithImage:
                                                withMetadata:)])
      [_delegate camera:self
          didFinishWithImage:image
                withMetadata:finalMetadata];
  } else {
    CGFloat newW = 256.0;
    CGFloat newH = 340.0;

    if (image.size.width > image.size.height) {
      newW = 340.0;
      newH = (newW * image.size.height) / image.size.width;
    }

    DBCameraSegueViewController *segue = [[DBCameraSegueViewController alloc]
        initWithImage:image
                thumb:[UIImage returnImage:image
                                  withSize:(CGSize) {newW, newH}]];
    [segue setTintColor:self.tintColor];
    [segue setSelectedTintColor:self.selectedTintColor];
    [segue setForceQuadCrop:_forceQuadCrop];
    [segue enableGestures:YES];
    [segue setDelegate:self.delegate];
    [segue setCapturedImageMetadata:finalMetadata];
    [segue setCameraSegueConfigureBlock:self.cameraSegueConfigureBlock];

    [self.navigationController pushViewController:segue animated:YES];
  }
}

- (void)captureImageFailedWithError:(NSError *)error {
  dispatch_async(dispatch_get_main_queue(), ^{
      [[[UIAlertView alloc] initWithTitle:@"Error"
                                  message:error.localizedDescription
                                 delegate:nil
                        cancelButtonTitle:@"Ok"
                        otherButtonTitles:nil, nil] show];
  });
}

- (void)captureSessionDidStartRunning {
  id camera = self.customCamera ?: _cameraView;
  CGRect bounds = [(UIView *)camera bounds];
  CGPoint screenCenter =
      (CGPoint) {CGRectGetMidX(bounds), CGRectGetMidY(bounds)};
  if ([camera respondsToSelector:@selector(drawFocusBoxAtPointOfInterest:
                                                               andRemove:)])
    [camera drawFocusBoxAtPointOfInterest:screenCenter andRemove:NO];
  if ([camera respondsToSelector:@selector(drawExposeBoxAtPointOfInterest:
                                                                andRemove:)])
    [camera drawExposeBoxAtPointOfInterest:screenCenter andRemove:NO];
}

- (void)openLibrary {
  if ([ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusDenied) {
    [UIView animateWithDuration:.3
        animations:^{
            [self.view setAlpha:0];
            [self.view setTransform:CGAffineTransformMakeScale(.8, .8)];
        }
        completion:^(BOOL finished) {
            DBCameraLibraryViewController *library =
                [[DBCameraLibraryViewController alloc]
                    initWithDelegate:self.containerDelegate];
            [library setTintColor:self.tintColor];
            [library setSelectedTintColor:self.selectedTintColor];
            [library setForceQuadCrop:_forceQuadCrop];
            [library setDelegate:self.delegate];
            [library setUseCameraSegue:self.useCameraSegue];
            [library
                setCameraSegueConfigureBlock:self.cameraSegueConfigureBlock];
            [library setLibraryMaxImageSize:self.libraryMaxImageSize];
            [self.containerDelegate switchFromController:self
                                            toController:library];
        }];
  } else {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc]
                initWithTitle:DBCameraLocalizedStrings(@"general.error.title")
                      message:DBCameraLocalizedStrings(@"pickerimage.nopolicy")
                     delegate:nil
            cancelButtonTitle:@"Ok"
            otherButtonTitles:nil, nil] show];
    });
  }
}

#pragma mark - CameraViewDelegate

- (void)cameraViewStartRecording {
  if (_processingPhoto)
    return;

  _processingPhoto = YES;

  [self.cameraManager captureImageForDeviceOrientation:_deviceOrientation];
}

- (void)cameraView:(UIView *)camera focusAtPoint:(CGPoint)point {
  if (self.cameraManager.videoInput.device.isFocusPointOfInterestSupported) {
    [self.cameraManager
        focusAtPoint:[self.cameraManager
                         convertToPointOfInterestFrom:
                             [[(DBCameraView *)camera previewLayer] frame]
                                          coordinates:point
                                                layer:[(DBCameraView *)camera
                                                              previewLayer]]];
  }
}

- (BOOL)cameraViewHasFocus {
  return self.cameraManager.hasFocus;
}

- (void)cameraView:(UIView *)camera exposeAtPoint:(CGPoint)point {
  if (self.cameraManager.videoInput.device.isExposurePointOfInterestSupported) {
    [self.cameraManager
        exposureAtPoint:
            [self.cameraManager
                convertToPointOfInterestFrom:[[(DBCameraView *)
                                                 camera previewLayer] frame]
                                 coordinates:point
                                       layer:[(DBCameraView *)
                                                 camera previewLayer]]];
  }
}

- (CGFloat)cameraMaxScale {
  return [self.cameraManager cameraMaxScale];
}

- (void)cameraCaptureScale:(CGFloat)scaleNum {
  [self.cameraManager setCameraMaxScale:scaleNum];
}

#pragma mark - UIApplicationDidEnterBackgroundNotification

- (void)applicationDidEnterBackground:(NSNotification *)notification {
  id modalViewController = self.presentingViewController;
  if (modalViewController)
    [self dismissCamera];
}

@end