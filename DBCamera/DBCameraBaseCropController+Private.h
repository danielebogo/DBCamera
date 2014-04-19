//
//  DBCameraBaseCropController+Private.h
//  CropImage
//
//  Created by Daniele Bogo on 19/04/14.
//  Copyright (c) 2014 Daniele Bogo. All rights reserved.
//

#import "DBCameraBaseCropController.h"
#import "DBCameraDelegate.h"

@interface DBCameraBaseCropController (Private)
@property (nonatomic, strong) UIView <DBCameraCropRect> *frameView;
@end