//
//  DBLibraryManager.m
//  DBCamera
//
//  Created by iBo on 05/03/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBLibraryManager.h"
#import "UIImage+Crop.h"

#define kCameraRollName @"camera roll"

@interface DBLibraryManager () {
    NSMutableArray *_assetGroups;
}
@property (nonatomic, strong) ALAssetsGroup *usedGroup;
@property (nonatomic, copy) ALAssetsGroupEnumerationResultsBlock assetsEnumerator;
@end

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

- (id) init
{
    self = [super init];
    
    if ( self ) {
        _assetGroups = [[NSMutableArray alloc] init];
    }
    
    return self;
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

- (void) loadGroupsAssetWithBlock:(GroupsCompletionBlock)blockhandler
{
    _getAllAssets = YES;
    _groupsCompletionBlock = blockhandler;
    __weak GroupsCompletionBlock block = _groupsCompletionBlock;
    [[self defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:self.assetGroupEnumerator
                                             failureBlock:^(NSError *error) {
                                                 block( NO, nil );
                                             }];
}

- (ALAssetsLibraryGroupsEnumerationResultsBlock) assetGroupEnumerator
{
    if ( _assetGroups.count > 0 )
        [_assetGroups removeAllObjects];
    
    __block NSMutableArray *groups = _assetGroups;
    __block BOOL blockGetAllAssets = _getAllAssets;
    __weak typeof(self) selfBlock = self;
    __weak GroupsCompletionBlock block = _groupsCompletionBlock;
    
    ALAssetsLibraryGroupsEnumerationResultsBlock groupsEnumerator = ^(ALAssetsGroup *group, BOOL *stop){
        if ( group ) {
            if ( group.numberOfAssets > 0 ) {
                [selfBlock setUsedGroup:group];
                [group enumerateAssetsUsingBlock:selfBlock.assetsEnumerator];
            }
        } else {
            if ( blockGetAllAssets ) {
                block ( YES, [groups copy] );
                groups = nil;
            }
        }
    };
    
    return groupsEnumerator;
}

- (ALAssetsGroupEnumerationResultsBlock) assetsEnumerator
{
    __block NSMutableArray *items = [NSMutableArray array];
    __block ALAsset *assetResult;
    __block BOOL blockGetAllAssets = _getAllAssets;
    
    __weak typeof(self) selfBlock = self;
    __weak NSMutableArray *assetGroupsBlock = _assetGroups;
    __weak LastItemCompletionBlock blockLastItem = _lastItemCompletionBlock;
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerator = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if ( result ) {
            if( [[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto] ) {
                [items addObject:[[result defaultRepresentation] url]];
                assetResult = result;
            }
        }
        
        if ( index == (NSInteger)[selfBlock.usedGroup numberOfAssets] - 1) {
            *stop = YES;
            
            if ( !blockGetAllAssets ) {
                UIImage *image = [UIImage imageWithCGImage:[assetResult thumbnail]];
                image = [UIImage createRoundedRectImage:image size:image.size roundRadius:8];
                dispatch_async(dispatch_get_main_queue(), ^{
                    blockLastItem( YES, image );
                });
            } else {
                NSString *groupPropertyName = (NSString *)[selfBlock.usedGroup valueForProperty:ALAssetsGroupPropertyName];
                NSString *groupPropertyPersistenID = (NSString *)[selfBlock.usedGroup valueForProperty:ALAssetsGroupPropertyPersistentID];
                NSUInteger propertyType = [[selfBlock.usedGroup valueForProperty:ALAssetsGroupPropertyType] intValue];
                
                NSDictionary *dictionaryGroup = @{ @"groupTitle":groupPropertyName, @"groupAssets":[[items reverseObjectEnumerator] allObjects], @"propertyType":@(propertyType), @"propertyID":groupPropertyPersistenID };
                
                if ( propertyType == ALAssetsGroupSavedPhotos )
                    [assetGroupsBlock insertObject:dictionaryGroup atIndex:0];
                else if ( [(NSArray *)dictionaryGroup[@"groupAssets"] count] > 0 )
                    [assetGroupsBlock addObject:dictionaryGroup];
                
                NSLog( @"Group %@", dictionaryGroup);
            }
            
            items = nil;
        }
    };
    
    return assetsEnumerator;
}

@end