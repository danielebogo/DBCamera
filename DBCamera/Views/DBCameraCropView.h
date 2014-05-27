//
//  DBCameraCropView.h
//  CropImage
//
//  Created by Daniele Bogo on 19/04/14.
//  Copyright (c) 2014 Daniele Bogo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCameraDelegate.h"

/**
 *  Show the crop rect bounds
 */
@interface DBCameraCropView : UIView <DBCameraCropRect>
@end