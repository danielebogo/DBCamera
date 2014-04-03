//
//  ADDropDownMenuItemView.m
//  ADDropDownMenuDemo
//
//  Created by Anton Domashnev on 16.12.13.
//  Copyright (c) 2013 Anton Domashnev. All rights reserved.
//

#import "ADDropDownMenuItemView.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define ADTextAlighnmentCenter (([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending) ? NSTextAlignmentCenter : UITextAlignmentCenter)

@interface ADDropDownMenuItemView()

@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, strong, readwrite) UIImageView *backgroundImageView;

@property (nonatomic, strong) NSMutableDictionary *statesBackgroundColor;
@property (nonatomic, strong) NSMutableDictionary *statesBackgroundImages;
@property (nonatomic, strong) NSMutableDictionary *statesTitleColor;

@end

@implementation ADDropDownMenuItemView

- (instancetype)initWithSize:(CGSize)size{
    
    if(self = [super initWithFrame: (CGRect){.size = size}]){
        
        self.statesBackgroundColor = [NSMutableDictionary dictionary];
        self.statesBackgroundImages = [NSMutableDictionary dictionary];
        self.statesTitleColor = [NSMutableDictionary dictionary];
        
        [self setDefaultValues];
        [self addBackgroundImageView];
        [self addTitleLabel];
        [self updateUIForCurrentState];
    }
    return self;
}

#pragma mark - Properties

- (void)setState:(ADDropDownMenuItemViewState)state{
    
    if(state != _state){
        _state = state;
        [self updateUIForCurrentState];
    }
}

#pragma mark - Helpers

- (void)setDefaultValues{
    
    [self setBackgroundColor:[UIColor colorWithRed:67./255. green:70./255. blue:71./255. alpha:1.] forState:ADDropDownMenuItemViewStateNormal];
    [self setBackgroundColor:[UIColor colorWithRed:55./255. green:59./255. blue:60./255. alpha:1.] forState:ADDropDownMenuItemViewStateSelected];
    [self setBackgroundColor:[UIColor colorWithRed:55./255. green:59./255. blue:60./255. alpha:1.] forState:ADDropDownMenuItemViewStateHighlighted];
    
    [self setTitleColor:[UIColor whiteColor] forState:ADDropDownMenuItemViewStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:ADDropDownMenuItemViewStateSelected];
    [self setTitleColor:[UIColor whiteColor] forState:ADDropDownMenuItemViewStateHighlighted];
}

- (void)updateUIForCurrentState{
    
    self.backgroundColor = self.statesBackgroundColor[@(self.state)];
    self.backgroundImageView.image = self.statesBackgroundImages[@(self.state)];
    self.titleLabel.textColor = self.statesTitleColor[@(self.state)];
}

#pragma mark - UI

- (void)addBackgroundImageView{
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame: self.bounds];
    [self addSubview: self.backgroundImageView];
}

- (void)addTitleLabel{
    
    self.titleLabel = [[UILabel alloc] initWithFrame: self.bounds];
    self.titleLabel.font = [UIFont systemFontOfSize: 16.];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self addSubview: self.titleLabel];
}

//161 163 163

#pragma mark - Interface

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(ADDropDownMenuItemViewState)state{
    
    NSParameterAssert(backgroundColor);
    self.statesBackgroundColor[@(state)] = backgroundColor;
    [self updateUIForCurrentState];
}

- (UIColor *)backgroundColorForState:(ADDropDownMenuItemViewState)state{
    return self.statesBackgroundColor[@(state)];
}

- (void)setBackgroundImage:(UIImage *)image forState:(ADDropDownMenuItemViewState)state{
    
    NSParameterAssert(image);
    self.statesBackgroundImages[@(state)] = image;
    [self updateUIForCurrentState];
}

- (UIImage *)backgroundImageForState:(ADDropDownMenuItemViewState)state{
    return self.statesBackgroundImages[@(state)];
}

- (void)setTitleColor:(UIColor *)color forState:(ADDropDownMenuItemViewState)state{
    
    NSParameterAssert(color);
    self.statesTitleColor[@(state)] = color;
}

- (UIColor *)titleColorForState:(ADDropDownMenuItemViewState)state{
    return self.statesTitleColor[@(state)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
