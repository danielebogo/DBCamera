//
//  DBCameraControllerProtocol.h
//  DBCamera
//
//  Created by Nikita Tuk on 09/10/16.
//  Copyright © 2016 PSSD - Daniele Bogo. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@protocol DBCameraControllerProtocol <NSObject>

/*
 *  Sets initial camera position if supported
 */
@property (nonatomic, assign) AVCaptureDevicePosition initialCameraPosition;

@end