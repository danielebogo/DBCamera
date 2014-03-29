//
//  DBCameraLibrary.m
//  DBCamera
//
//  Created by iBo on 06/03/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraLibrary.h"
#import "DBLibraryManager.h"
#import "DBCollectionViewCell.h"
#import "DBCollectionViewFlowLayout.h"
#import "DBCameraSegueViewController.h"
#import "UIImage+Crop.h"
#import "DBCameraMacros.h"
#import "ADDropDownMenuView.h"
#import "ADDropDownMenuItemView.h"

#ifndef DBCameraLocalizedStrings
#define DBCameraLocalizedStrings(key) \
NSLocalizedStringFromTable(key, @"DBCamera", nil)
#endif

#define kItemIdentifier @"ItemIdentifier"

@interface DBCameraLibrary () <UICollectionViewDataSource, UICollectionViewDelegate,ADDropDownMenuDelegate> {
    NSMutableArray *_items;
    UICollectionView *_collectionView;
    NSArray *_groups;
}
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIView *topContainerBar, *loading;;
@end

@implementation DBCameraLibrary

- (id) initWithDelegate:(id<DBCameraContainerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _containerDelegate = delegate;
        _items = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.topContainerBar];
   
    CGRect frame = (CGRect){ 0, CGRectGetMaxY(self.topContainerBar.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.topContainerBar.frame) };
    
    _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:[[DBCollectionViewFlowLayout alloc] init]];
    [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
    [_collectionView setBackgroundColor:self.view.backgroundColor];
    [_collectionView registerClass:[DBCollectionViewCell class] forCellWithReuseIdentifier:kItemIdentifier];
    [self.view addSubview:_collectionView];
    
    [self.view addSubview:self.loading];
}



- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    __weak typeof(self) blockSelf = self;
    
    [[DBLibraryManager sharedInstance] loadGroupsWithBlock:^(BOOL success, NSArray *items) {
        
        NSMutableArray* dropArray = [NSMutableArray array];
        _groups = items;
        for (ALAssetsGroup* g in items) {
            if ([items indexOfObject:g] == 0) [blockSelf loadAssetWithGroup:g]; //go ahead and load the camera roll's images

            ADDropDownMenuItemView *item = [[ADDropDownMenuItemView alloc] initWithSize: CGSizeMake(320, 30)];
            NSInteger gCount = [g numberOfAssets];
            item.titleLabel.text = [NSString stringWithFormat:@"%@ (%ld)",[g valueForProperty:ALAssetsGroupPropertyName], (long)gCount];
            item.tag = [items indexOfObject:g];
            [item setBackgroundColor:[UIColor blackColor] forState:ADDropDownMenuItemViewStateNormal];
            [item setBackgroundColor:[UIColor blackColor] forState:ADDropDownMenuItemViewStateSelected];
            [item setBackgroundColor:[UIColor blackColor] forState:ADDropDownMenuItemViewStateHighlighted];
            [dropArray addObject:item];
        }
        ADDropDownMenuView *dropDownMenuView = [[ADDropDownMenuView alloc] initAtOrigin:CGPointMake(0, 15) withItemsViews:dropArray];
        dropDownMenuView.separatorColor = [UIColor blackColor];
        dropDownMenuView.delegate = blockSelf;
        
        [blockSelf.view addSubview:dropDownMenuView];
        [blockSelf.view addSubview:blockSelf.closeButton];
    }];
    
    
}


-(void)loadAssetWithGroup:(ALAssetsGroup*) assetGroup {
    __weak NSMutableArray *blockItems = _items;
    __weak UICollectionView *blockCollection = _collectionView;
    __weak typeof(self) blockSelf = self;
    
    [[DBLibraryManager sharedInstance] loadAssetsWithGroup:assetGroup andBlock:^(BOOL success, NSArray *items) {
        if ( success ) {
            [blockSelf.loading removeFromSuperview];
            if ( items.count > 0) {
                [blockItems setArray:[[items reverseObjectEnumerator] allObjects]];
                [blockCollection reloadData];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:DBCameraLocalizedStrings(@"general.error.title") message:DBCameraLocalizedStrings(@"pickerimage.nophoto") delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                });
            }
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) close
{
    [UIView animateWithDuration:.3 animations:^{
        [self.view setAlpha:0];
        [self.view setTransform:CGAffineTransformMakeScale(.8, .8)];
    } completion:^(BOOL finished) {
        [self.containerDelegate backFromController:self];
    }];
}

- (UIView *) loading
{
    if( !_loading ) {
        _loading = [[UIView alloc] initWithFrame:(CGRect){ 0, 0, 100, 100 }];
        [_loading.layer setCornerRadius:10];
        [_loading setBackgroundColor:RGBColor(0x000000, .7)];
        [_loading setCenter:self.view.center];
        [_loading setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
        
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activity setCenter:(CGPoint){ CGRectGetMidX(_loading.bounds), CGRectGetMidY(_loading.bounds) }];
        [_loading addSubview:activity];
        [activity startAnimating];
    }
    
    return _loading;
}

- (UIView *) topContainerBar
{
    if ( !_topContainerBar ) {
        _topContainerBar = [[UIView alloc] initWithFrame:(CGRect){ 0, 0, CGRectGetWidth(self.view.bounds), 65 }];
        _topContainerBar.backgroundColor = [UIColor blackColor];
    }
    return _topContainerBar;
}

- (UIButton *) closeButton
{
    if ( !_closeButton ) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setBackgroundColor:[UIColor clearColor]];
        [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeButton setFrame:(CGRect){ self.view.frame.size.width-40,  15, 30, 30 }];
        [_closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _closeButton;
}

#pragma mark - ADDropDownMenuDelegate

- (void)ADDropDownMenu:(ADDropDownMenuView *)view didSelectItem:(ADDropDownMenuItemView *)item {
    ALAssetsGroup* g = [_groups objectAtIndex:item.tag];
    [self loadAssetWithGroup:g];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return _items.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DBCollectionViewCell *item = [collectionView dequeueReusableCellWithReuseIdentifier:kItemIdentifier forIndexPath:indexPath];
    [item.itemImage setImage:nil];
    
    if ( _items.count > 0) {
        __weak DBCollectionViewCell *blockItem = item;
        [[[DBLibraryManager sharedInstance] defaultAssetsLibrary] assetForURL:(NSURL *)_items[indexPath.item]  resultBlock:^(ALAsset *asset) {
            UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
            [blockItem.itemImage setImage:image];
        } failureBlock:nil];
    }
    
    return item;
}

#pragma mark - UICollectionViewDelegate

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:self.loading];
        
        __weak typeof(self) blockSelf = self;
        [[[DBLibraryManager sharedInstance] defaultAssetsLibrary] assetForURL:(NSURL *)_items[indexPath.item]  resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
            UIImage *image = [UIImage imageWithCGImage:[defaultRep fullResolutionImage]
                                                 scale:[defaultRep scale]
                                           orientation:[[asset valueForProperty:ALAssetPropertyOrientation] integerValue]];
            
            if ( !blockSelf.useCameraSegue ) {
                if ( [blockSelf.delegate respondsToSelector:@selector(captureImageDidFinish:withMetadata:)] )
                    [blockSelf.delegate captureImageDidFinish:[image rotateUIImage]
                                                 withMetadata:[defaultRep metadata]];
            } else {
                DBCameraSegueViewController *segue = [[DBCameraSegueViewController alloc] init];
                [segue setCapturedImage:[image rotateUIImage]];
                [segue setCapturedImageMetadata:[defaultRep metadata]];
                [segue setDelegate:blockSelf.delegate];
                [blockSelf.navigationController pushViewController:segue animated:YES];
            }
            
            [blockSelf.loading removeFromSuperview];
            
        } failureBlock:nil];
    });
}

@end