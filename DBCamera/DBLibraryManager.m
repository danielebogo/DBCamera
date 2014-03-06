//
//  DBLibraryManager.m
//  DBCamera
//
//  Created by iBo on 05/03/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBLibraryManager.h"
#import "UIImage+Crop.h"

@implementation DBLibraryManager

+ (DBLibraryManager *) sharedInstance
{
    static DBLibraryManager * sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[DBLibraryManager alloc] init];
    });
    return sharedInstance;
}

- (ALAssetsLibrary *) defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

- (void) loadLastItemWithBlock:(LastItemCompletionBlock)blockhandler
{
    _getAllAssets = NO;
    _lastItemCompletionBlock = blockhandler;
    __weak LastItemCompletionBlock block = _lastItemCompletionBlock;
    [[self defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:self.assetGroupEnumerator
                                             failureBlock:^(NSError *error) {
                                                 block( NO, nil );
                                             }];
}

- (void) loadAssetsWithBlock:(ItemsCompletionBlock)blockhandler
{
    _getAllAssets = YES;
    _itemsCompletionBlock = blockhandler;
    __weak ItemsCompletionBlock block = _itemsCompletionBlock;
    [[self defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:self.assetGroupEnumerator
                                             failureBlock:^(NSError *error) {
                                                 block( NO, nil );
                                             }];
}

- (AssetGroupEnumerator) assetGroupEnumerator
{
    __block NSMutableArray *items = [NSMutableArray array];
    __block BOOL blockGetAllAssets = _getAllAssets;
    __weak ItemsCompletionBlock block = _itemsCompletionBlock;
    __weak LastItemCompletionBlock blockLastItem = _lastItemCompletionBlock;
    __block ALAsset *assetResult;
    
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop){
        if ( group ) {
            void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if ( result ) {
                    if( [[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto] ) {
                        [items addObject:[[result defaultRepresentation] url]];
                        assetResult = result;
                    }
                }
                
                if ( index == (NSInteger)[group numberOfAssets] - 1) {
                    *stop = YES;
                    
                    if ( !blockGetAllAssets ) {
                        UIImage *image = [UIImage imageWithCGImage:[assetResult thumbnail]];
                        image = [UIImage createRoundedRectImage:image size:image.size roundRadius:8];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            blockLastItem( YES, image );
                        });
                    } else
                        block(YES, [items copy] );
                    
                    items = nil;
                }
            };
            
            [group enumerateAssetsUsingBlock:assetEnumerator];
        }
    };
    
    return assetGroupEnumerator;
}

@end