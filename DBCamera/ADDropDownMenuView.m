//
//  ADDropDownMenuView.m
//  ADDropDownMenuDemo
//
//  Created by Anton Domashnev on 16.12.13.
//  Copyright (c) 2013 Anton Domashnev. All rights reserved.
//

#import "ADDropDownMenuView.h"
#import "ADDropDownMenuItemView.h"

#define SEPARATOR_VIEW_HEIGHT 1
#define AD_DROP_DOWN_MENU_ANIMATION_DURATION 0.3
#define DIM_VIEW_TAG 1919101910

@interface ADDropDownMenuView()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, strong, readwrite) NSMutableArray *itemsViews;
@property (nonatomic, strong) NSMutableArray *separators;

@property (nonatomic, unsafe_unretained, readwrite) BOOL isOpen;
@property (nonatomic, unsafe_unretained) BOOL isAnimating;
@property (nonatomic, unsafe_unretained) BOOL shouldContractOnTouchesEnd;

@property (nonatomic, strong) NSArray *initialItems;

@end

@implementation ADDropDownMenuView

- (instancetype)initAtOrigin:(CGPoint)origin withItemsViews:(NSArray *)itemsViews{
    
    NSAssert(itemsViews.count > 0, @"ADDropDownMenuView should has at least one item view");
    
    if(self = [super initWithFrame: (CGRect){.origin = origin,
                                             .size = CGSizeMake(((ADDropDownMenuItemView *)[itemsViews firstObject]).frame.size.width,
                                                                [ADDropDownMenuView contractedHeightForItemsViews:itemsViews])}]){
        self.backgroundColor = [UIColor clearColor];
        self.itemsViews = [itemsViews mutableCopy];
        self.separators = [NSMutableArray array];
                                 
        [self addDimView];
        [self addContainerView];
        [self addItemsViewsAndSeparators];
        [self selectItem: [self.itemsViews firstObject]];
	self.initialItems = [NSArray arrayWithArray:itemsViews];
    }
    
    return self;
}

#pragma mark - Properties

- (void)setSeparatorColor:(UIColor *)separatorColor{
    
    _separatorColor = separatorColor;
    [self.separators enumerateObjectsUsingBlock:^(UIView *separatorView, NSUInteger idx, BOOL *stop) {
        separatorView.backgroundColor = separatorColor;
    }];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    UIView *itemView = [self hitTest:locationPoint withEvent:event];
    if([itemView isKindOfClass: [ADDropDownMenuItemView class]]){
        [self highlightItem: (ADDropDownMenuItemView *)itemView];
        [self expand];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    UIView* itemView = [self hitTest:locationPoint withEvent:event];
    if([itemView isKindOfClass: [ADDropDownMenuItemView class]]){
        [self highlightItem: (ADDropDownMenuItemView *)itemView];
    }
    else{
        [self highlightItem: nil];
    }
    
    self.shouldContractOnTouchesEnd = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView: self];
    if(touchLocation.y > 0){
        [self userDidEndTouches:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if(!self.isAnimating){
        [self userDidEndTouches:touches withEvent:event];
    }
}

- (void)userDidEndTouches:(NSSet *)touches withEvent:(UIEvent *)event{
    
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    UIView* itemView = [self hitTest:locationPoint withEvent:event];
    
    if(itemView.tag == DIM_VIEW_TAG){
        self.shouldContractOnTouchesEnd = NO;
        [self selectItem: [self.itemsViews firstObject]];
        [self contract];
    }
    else{
        if(self.shouldContractOnTouchesEnd){
            
            if([itemView isKindOfClass: [ADDropDownMenuItemView class]]){
                self.shouldContractOnTouchesEnd = NO;
                [self selectItem: (ADDropDownMenuItemView *)itemView];
                [self exchangeItem:(ADDropDownMenuItemView *)itemView withItem:[self.itemsViews firstObject]];
                
                if([self.delegate respondsToSelector:@selector(ADDropDownMenu:didSelectItem:)]){
                    [self.delegate ADDropDownMenu:self didSelectItem:(ADDropDownMenuItemView *)itemView];
                }
                
                [self contract];
            }
        }
        else{
            self.shouldContractOnTouchesEnd = YES;
            [self selectItem: [self.itemsViews firstObject]];
        }
    }
}

#pragma mark - UI

- (void)addDimView{

    self.dimView = [[UIView alloc] initWithFrame: self.bounds];
    self.dimView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.dimView.backgroundColor = [UIColor blackColor];
    self.dimView.alpha = 0.;
    self.dimView.tag = DIM_VIEW_TAG;
    [self addSubview: self.dimView];
}

- (void)addContainerView{
    
    self.containerView = [[UIView alloc] initWithFrame: ((ADDropDownMenuItemView *)[self.itemsViews firstObject]).bounds];
    self.containerView.backgroundColor = [UIColor clearColor];
    self.containerView.clipsToBounds = YES;
    [self addSubview: self.containerView];
}

- (void)addItemsViewsAndSeparators{
    
    NSUInteger itemsCount = self.itemsViews.count;
    __block CGFloat itemY = 0;
    
    [self.itemsViews enumerateObjectsUsingBlock:^(ADDropDownMenuItemView *item, NSUInteger idx, BOOL *stop) {
        
        item.frame = (CGRect){.origin = CGPointMake(item.frame.origin.x, itemY), .size = item.frame.size};
        [self.containerView addSubview: item];
        
        if(idx < itemsCount - 1){
            UIView *separatorView = [self separatorView];
            separatorView.frame = (CGRect){.origin = CGPointMake(separatorView.frame.origin.x, itemY + item.frame.size.height), .size = separatorView.frame.size};
            [self.containerView addSubview: separatorView];
            itemY = separatorView.frame.size.height + separatorView.frame.origin.y;
        }
    }];
}

- (UIView *)separatorView{
    
    UIView *separatorView = [[UIView alloc] initWithFrame: (CGRect){.size = CGSizeMake(self.bounds.size.width, SEPARATOR_VIEW_HEIGHT)}];
    separatorView.backgroundColor = self.separatorColor;
    [self.separators addObject: separatorView];
    return separatorView;
}

#pragma mark - Helpers

- (void)exchangeItem:(ADDropDownMenuItemView *)item withItem:(ADDropDownMenuItemView *)item2{
    
    CGRect itemRect = item.frame;
    item.frame = item2.frame;
    item2.frame = itemRect;
    
    [self.itemsViews exchangeObjectAtIndex:[self.itemsViews indexOfObject: item] withObjectAtIndex:[self.itemsViews indexOfObject: item2]];
}

- (void)highlightItem:(ADDropDownMenuItemView *)item{
    
    [self.itemsViews enumerateObjectsUsingBlock:^(ADDropDownMenuItemView *obj, NSUInteger idx, BOOL *stop) {
        if(obj == item){
            obj.state = ADDropDownMenuItemViewStateHighlighted;
        }
        else{
            obj.state = ADDropDownMenuItemViewStateNormal;
        }
    }];
}

- (void)selectItem:(ADDropDownMenuItemView *)item{
    
    [self.itemsViews enumerateObjectsUsingBlock:^(ADDropDownMenuItemView *obj, NSUInteger idx, BOOL *stop) {
        if(obj == item){
            obj.state = ADDropDownMenuItemViewStateSelected;
        }
        else{
            obj.state = ADDropDownMenuItemViewStateNormal;
        }
    }];
}

+ (CGFloat)contractedHeightForItemsViews:(NSArray *)itemsViews{
    ADDropDownMenuView *item = [itemsViews firstObject];
    return item.frame.size.height;
}

+ (CGFloat)expandedHeightForItemsViews:(NSArray *)itemsViews{
    NSUInteger itemsCount = itemsViews.count;
    ADDropDownMenuView *someItem = [itemsViews firstObject];
    return itemsCount * someItem.frame.size.height + SEPARATOR_VIEW_HEIGHT * MAX(itemsCount - 1, 0);
}

- (void)expand{
    
    self.isAnimating = YES;
    CGRect expandedFrame = (CGRect){.origin = self.containerView.frame.origin,
        .size = CGSizeMake(self.containerView.frame.size.width, [ADDropDownMenuView expandedHeightForItemsViews: self.itemsViews])};
    
    if([self.delegate respondsToSelector:@selector(ADDropDownMenu:willExpandToRect:)]){
        [self.delegate ADDropDownMenu:self willExpandToRect:expandedFrame];
    }
    
    self.frame = (CGRect){.origin = self.frame.origin, .size = CGSizeMake(self.frame.size.width, [UIScreen mainScreen].applicationFrame.size.height)};
    [UIView animateWithDuration:AD_DROP_DOWN_MENU_ANIMATION_DURATION animations:^{
        self.dimView.alpha = 0.4;
        self.containerView.frame = expandedFrame;
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
    }];
    
    self.isOpen = YES;
}

- (void)contract{
    
    self.isAnimating = YES;
    CGRect contractedFrame = (CGRect){.origin = self.containerView.frame.origin,
        .size = CGSizeMake(self.containerView.frame.size.width, [ADDropDownMenuView contractedHeightForItemsViews: self.itemsViews])};
    
    if([self.delegate respondsToSelector:@selector(ADDropDownMenu:willContractToRect:)]){
        [self.delegate ADDropDownMenu:self willContractToRect:contractedFrame];
    }
    
    self.frame = (CGRect){.origin = self.frame.origin, .size = CGSizeMake(self.frame.size.width, [ADDropDownMenuView contractedHeightForItemsViews: self.itemsViews])};
    [UIView animateWithDuration:AD_DROP_DOWN_MENU_ANIMATION_DURATION animations:^{
        self.dimView.alpha = 0.;
        self.containerView.frame = contractedFrame;
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
    }];
    
    self.isOpen = NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setSelectedAtIndex:(NSInteger)index {
    ADDropDownMenuItemView *itemView = self.initialItems[index];
	self.shouldContractOnTouchesEnd = NO;
	[self selectItem: itemView];
	[self exchangeItem: itemView withItem:[self.itemsViews firstObject]];
	if([self.delegate respondsToSelector:@selector(ADDropDownMenu:didSelectItem:)]){
		[self.delegate ADDropDownMenu:self didSelectItem:itemView];
	}
	[self contract];
}

@end
