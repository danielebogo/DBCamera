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
platform :ios, '6.0' 
# Or platform :osx, '10.8'
pod 'DBCamera', '~> 0.1'
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
    [self presentViewController:[[DBCameraViewController alloc] initWithDelegate:self] animated:YES completion:nil];
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

###Version
2.0.3

###Created By

[Daniele Bogo](https://github.com/danielebogo)
