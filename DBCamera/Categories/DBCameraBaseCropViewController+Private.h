//
//  DBCameraBaseCropController+Private.h
//  CropImage
//
//  Created by Daniele Bogo on 19/04/14.
//  Copyright (c) 2014 Daniele Bogo. All rights reserved.
//

#import "DBCameraBaseCropViewController.h"
#import "DBCameraDelegate.h"

/**
 *  DBCameraBaseCropViewController private method
 */
@interface DBCameraBaseCropViewController (Private)
/**
 *  UIView complies with the DBCameraCropRect protocol
 */
@property (nonatomic, strong) UIView <DBCameraCropRect> *frameView;
@end