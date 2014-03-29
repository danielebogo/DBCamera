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
    [[self defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:self.lastAssetGroupEnumerator
                                             failureBlock:^(NSError *error) {
                                                 block( NO, nil );
                                             }];
}


-(void) loadGroupsWithBlock:(ItemsCompletionBlock)blockhandler {
    __block NSMutableArray *albumItems = [NSMutableArray array];
    __weak ItemsCompletionBlock block = blockhandler;
    
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
    {
        if (group == nil) {
            blockhandler(YES,[albumItems copy]);
            *stop = YES;
            return;
        }
        
        // added fix for camera albums order
        NSString *sGroupPropertyName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
        NSUInteger nType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
        
        if ([[sGroupPropertyName lowercaseString] isEqualToString:@"camera roll"] && nType == ALAssetsGroupSavedPhotos) {
            [albumItems insertObject:group atIndex:0];
        }
        else {
            [albumItems addObject:group];
        }
    };
    
    // Enumerate Albums
    [[self defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetGroupEnumerator failureBlock:^(NSError *error) {
        block( NO, nil );
    }];
    
}



- (void) loadAssetsWithGroup:(ALAssetsGroup*)group andBlock:(ItemsCompletionBlock)blockhandler {
    __block NSMutableArray *items = [NSMutableArray array];
    _itemsCompletionBlock = blockhandler;
    __weak ItemsCompletionBlock block = _itemsCompletionBlock;
    __block ALAsset *assetResult;
    
    void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop2) {
        if ( result ) {
            if( [[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto] ) {
                [items addObject:[[result defaultRepresentation] url]];
                assetResult = result;
            }
        }
        
        if ( index == (NSInteger)[group numberOfAssets] - 1) {
            *stop2 = YES;
            block(YES,[items copy]);
        }
        
    };
    [group enumerateAssetsUsingBlock:assetEnumerator];
}


- (AssetGroupEnumerator) lastAssetGroupEnumerator
{
    __weak LastItemCompletionBlock blockLastItem = _lastItemCompletionBlock;
    __block ALAsset *assetResult;
    
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop1){
        if ( group ) {
            void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop2) {
                assetResult = result;
                if ( index == (NSInteger)[group numberOfAssets] - 1) {
                    *stop2 = YES;
                    UIImage *image = [UIImage imageWithCGImage:[assetResult thumbnail]];
                    image = [UIImage createRoundedRectImage:image size:image.size roundRadius:8];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        blockLastItem( YES, image );
                    });
                }
            };
            [group enumerateAssetsUsingBlock:assetEnumerator];
        }
    };
    
    return assetGroupEnumerator;
}

@end