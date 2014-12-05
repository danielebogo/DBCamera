//
//  DBCameraVideoSegueViewController.h
//  DBCamera
//
//  Created by dw_iOS on 14-10-14.
//  Copyright (c) 2014年 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <GPUImageMovie.h>

@interface DBCameraVideoSegueViewController : UIViewController

@property (nonatomic, strong) GPUImageMovie *imageMovie;

- (instancetype)initWithVideoALAsset:(ALAsset *)videoAsset;

@end
