//
//  DBPhotoProcessingControllerProtocol.h
//  DBCamera
//
//  Created by Nikita Tuk on 09/10/16.
//  Copyright © 2016 PSSD - Daniele Bogo. All rights reserved.
//

@protocol DBPhotoProcessingControllerProtocol <NSObject>

@property (nonatomic, nonnull, strong, readonly) UIButton *cropButton;
@property (nonatomic, assign) BOOL filtersBarVisible;

@end