DBCamera
========

Inspired by [CropImageSample] (https://github.com/kishikawakatsumi/CropImageSample), DBCamera is a simple custom camera with AVFoundation. At the moment it has been tested only on iOS 7.

<p align="left"><img src="http://paperstreetsoapdesign.com/development/dbcamera/github/dbcamera_screen.png" width="320px" height="568px" /></p>

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
platform :ios, '7.0' 
pod 'DBCamera', '~> 0.4'
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
#pragma mrak - DBCameraViewControllerDelegate

- (void) captureImageDidFinish:(UIImage *)image
{
    [_imageView setImage:image];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}
```
You can also create a custom interface, using a subclass of DBCameraView
```objective-c
#import "DBCameraView.h"

@interface CustomCamera : DBCameraView
- (void) buildIntarface;
@end
```
```objective-c
#import "CustomCamera.h"

@interface CustomCamera ()
@property (nonatomic, strong) UIButton *closeButton;
@end

@implementation CustomCamera

- (void) buildIntarface
{
    [self addSubview:self.closeButton];
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

@end
```
```objective-c
//Present DBCameraViewController with a custom view.
- (void) openCustomCamera:(id)sender
{
    CustomCamera *camera = [CustomCamera initWithFrame:[[UIScreen mainScreen] bounds]];
    [camera buildIntarface];
    
    [self presentViewController:[[DBCameraViewController alloc] initWithDelegate:self cameraView:camera]
                       animated:YES completion:nil];
}
```

###Version
0.4

###Created By

[Daniele Bogo](https://github.com/danielebogo)
