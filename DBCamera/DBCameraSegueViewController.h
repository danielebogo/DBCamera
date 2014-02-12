//
//  DBCameraUseViewController.h
//  DBCamera
//
//  Created by iBo on 11/02/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCameraDelegate.h"

@interface DBCameraSegueViewController : UIViewController
@property (nonatomic, weak) id <DBCameraViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImage *capturedImage;
@end