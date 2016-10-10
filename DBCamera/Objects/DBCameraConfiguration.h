//
//  DBCameraConfiguration.h
//  DBCamera
//
//  Created by Nikita Tuk on 09/10/16.
//  Copyright © 2016 PSSD - Daniele Bogo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBPhotoProcessingControllerProtocol.h"

@interface DBCameraConfiguration : NSObject

@property (nonatomic, nullable, copy) void (^configureProcessingController)(UIViewController <DBPhotoProcessingControllerProtocol> * _Nonnull controller);

@end
