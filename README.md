DBCamera
========

Inspired by [CropImageSample] (https://github.com/kishikawakatsumi/CropImageSample), DBCamera is a simple custom camera with AVFoundation.

![Alt text](http://paperstreetsoapdesign.com/development/dbcamera/github/dbcamera_screen_5.png)

##Getting Started

### Installation

The recommended approach for installating DBCamera is via the [CocoaPods](http://cocoapods.org/) package manager, as it provides flexible dependency management and dead simple installation. For best results, it is recommended that you install via CocoaPods **>= 0.16.0** using Git **>= 1.8.0** installed via Homebrew.

#### via CocoaPods

Install CocoaPods if not already available:

``` bash
$ [sudo] gem install cocoapods
$ pod setup
```

Change to the directory of your Xcode project, and Create and Edit your Podfile and add DBCamera:

``` bash
$ cd /path/to/MyProject
$ touch Podfile
$ edit Podfile
platform :ios, '6.0' 
pod 'DBCamera', '~> 1.0.2'
```

Install into your project:

``` bash
$ pod install
```

Open your project in Xcode from the .xcworkspace file (not the usual project file)

``` bash
$ open MyProject.xcworkspace
```
## Integration

DBCamera has a simple integration:

```objective-c
#import "DBCameraViewController.h"
```

```objective-c
//Add DBCameraViewControllerDelegate protocol
@interface RootViewController () <DBCameraViewControllerDelegate>
```

```objective-c
//Present DBCameraViewController
- (void) openCamera:(id)sender
{
    [self presentViewController:[DBCameraViewController initWithDelegate:self] animated:YES completion:nil];
}
```

```objective-c
//Use your captured image
#pragma mark - DBCameraViewControllerDelegate

- (void) captureImageDidFinish:(UIImage *)image
{
    [_imageView setImage:image];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}
```
By default, DBCameraViewController has another controller to display the image preview.
When you create DBCameraViewController instance, you can set ``` useCameraSegue: ``` NO, to avoid it.
```objective-c
- (void) openCameraWithoutSegue
{
    DBCameraViewController *cameraController = [DBCameraViewController initWithDelegate:self];
    [cameraController setUseCameraSegue:NO];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cameraController];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}
```

You can also create a custom interface, using a subclass of DBCameraView
```objective-c
#import "DBCameraView.h"

@interface CustomCamera : DBCameraView
- (void) buildInterface;
@end
```
```objective-c
#import "CustomCamera.h"

@interface CustomCamera ()
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) CALayer *focusBox, *exposeBox;
@end

@implementation CustomCamera

- (void) buildInterface
{
    [self addSubview:self.closeButton];
    
    [self.previewLayer addSublayer:self.focusBox];
    [self.previewLayer addSublayer:self.exposeBox];
    
    [self createGesture];
}

- (UIButton *) closeButton
{
    if ( !_closeButton ) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setBackgroundColor:[UIColor redColor]];
        [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeButton setFrame:(CGRect){ CGRectGetMidX(self.bounds) - 15, 17.5f, 30, 30 }];
        [_closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _closeButton;
}

- (void) close
{
    if ( [self.delegate respondsToSelector:@selector(closeCamera)] )
        [self.delegate closeCamera];
}

#pragma mark - Focus / Expose Box

- (CALayer *) focusBox
{
    if ( !_focusBox ) {
        _focusBox = [[CALayer alloc] init];
        [_focusBox setCornerRadius:45.0f];
        [_focusBox setBounds:CGRectMake(0.0f, 0.0f, 90, 90)];
        [_focusBox setBorderWidth:5.f];
        [_focusBox setBorderColor:[[UIColor whiteColor] CGColor]];
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
        [_exposeBox setBorderColor:[[UIColor redColor] CGColor]];
        [_exposeBox setOpacity:0];
    }
    
    return _exposeBox;
}

- (void) drawFocusBoxAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove
{
    [super draw:_focusBox atPointOfInterest:point andRemove:remove];
}

- (void) drawExposeBoxAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove
{
    [super draw:_exposeBox atPointOfInterest:point andRemove:remove];
}

@end
```
```objective-c
//Present DBCameraViewController with a custom view.
- (void) openCustomCamera:(id)sender
{
    CustomCamera *camera = [CustomCamera initWithFrame:[[UIScreen mainScreen] bounds]];
    [camera buildInterface];
    
    [self presentViewController:[[DBCameraViewController alloc] initWithDelegate:self cameraView:camera]
                       animated:YES completion:nil];
}
```

###iOS Min Required
6.0

###Version
1.0.2

###Created By

[Daniele Bogo](https://github.com/danielebogo)

###Credits

[Jack](https://github.com/xhzengAIB) - Add GridView, Pinch & Pan gestures on camera view
