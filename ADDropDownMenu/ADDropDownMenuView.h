//
//  ADDropDownMenuView.h
//  ADDropDownMenuDemo
//
//  Created by Anton Domashnev on 16.12.13.
//  Copyright (c) 2013 Anton Domashnev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ADDropDownMenuView;
@class ADDropDownMenuItemView;

@protocol ADDropDownMenuDelegate <NSObject>

@optional
- (void)ADDropDownMenu:(ADDropDownMenuView *)view didSelectItem:(ADDropDownMenuItemView *)item;
- (void)ADDropDownMenu:(ADDropDownMenuView *)view willExpandToRect:(CGRect)rect;
- (void)ADDropDownMenu:(id)view willContractToRect:(CGRect)rect;

@end

@interface ADDropDownMenuView : UIView

@property (nonatomic, strong, readonly) NSMutableArray *itemsViews;
@property (nonatomic, strong) UIColor *separatorColor;
@property (nonatomic, unsafe_unretained, readonly) BOOL isOpen;

@property (nonatomic, weak) id<ADDropDownMenuDelegate> delegate;

- (instancetype)initAtOrigin:(CGPoint)origin withItemsViews:(NSArray *)itemsViews;

- (void)setSelectedAtIndex:(NSInteger)index;

@end
