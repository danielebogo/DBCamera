//
//  DBCameraSegueViewController.h
//  CropImage
//
//  Created by Daniele Bogo on 19/04/14.
//  Copyright (c) 2014 Daniele Bogo. All rights reserved.
//

#import "DBCameraBaseCropViewController.h"
#import "DBCameraDelegate.h"

@interface DBCameraSegueViewController : DBCameraBaseCropViewController <DBCameraCropRect>
@property (nonatomic, weak) id <DBCameraViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDictionary *capturedImageMetadata;

- (id) initWithImage:(UIImage *)image thumb:(UIImage *)thumb;
- (void) createInterface;
@end