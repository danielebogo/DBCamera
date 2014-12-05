//
//  DBCameraCollectionViewController.m
//  DBCamera
//
//  Created by iBo on 08/04/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCameraCollectionViewController.h"
#import "DBCollectionViewFlowLayout.h"
#import "DBCollectionViewCell.h"
#import "DBLibraryManager.h"

@interface DBCameraCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSString *_collectionIdentifier;
}

@end

@implementation DBCameraCollectionViewController

- (id)initWithCollectionIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        // Custom initialization
        _collectionIdentifier = identifier;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:[[DBCollectionViewFlowLayout alloc] init]];
    [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
    [_collectionView setBackgroundColor:self.view.backgroundColor];
    [_collectionView registerClass:[DBCollectionViewCell class] forCellWithReuseIdentifier:_collectionIdentifier];
    [self.view addSubview:_collectionView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger) collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return _items.count > 0 ? _items.count : 0;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DBCollectionViewCell *item = [collectionView dequeueReusableCellWithReuseIdentifier:_collectionIdentifier forIndexPath:indexPath];
    [item.itemImage setImage:nil];
    [item.itemDuration setText:nil];
    item.itemDuration.hidden = YES;
    
    if ( _items.count > 0) {
        __weak DBCollectionViewCell *blockItem = item;
        [[[DBLibraryManager sharedInstance] defaultAssetsLibrary] assetForURL:(NSURL *)_items[indexPath.item]  resultBlock:^(ALAsset *asset) {
            UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
            [blockItem.itemImage setImage:image];
            NSString *assetPropertyType = [asset valueForProperty:ALAssetPropertyType];
            if ([assetPropertyType isEqualToString:ALAssetTypeVideo]) {
                blockItem.itemDuration.hidden = NO;
                double value = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
                
                NSNumber *theDouble = [NSNumber numberWithDouble:round(value)];
                
                int inputSeconds = [theDouble intValue];
                int hours =  inputSeconds / 3600;
                int minutes = ( inputSeconds - hours * 3600 ) / 60;
                int seconds = inputSeconds - hours * 3600 - minutes * 60;
                
                NSString *theTime = [NSString stringWithFormat:@"%.2d:%.2d:%.2d", hours, minutes, seconds];
                
                blockItem.itemDuration.text = theTime;
            }
            
        } failureBlock:nil];
    }
    
    return item;
}

#pragma mark - UICollectionViewDelegate

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [_collectionControllerDelegate collectionView:collectionView itemURL:(NSURL *)_items[indexPath.item]];
}

@end