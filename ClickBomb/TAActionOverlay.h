//
//  TAActionOverlay.h
//  TAActionOverlay
//
//  Created by Hale Chan on 15/3/24.
//  Copyright (c) 2015年 Tips4app Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TAActionOverlayDirection){
    TAActionOverlayDirectionTop,
    TAActionOverlayDirectionLeft,
    TAActionOverlayDirectionBottom,
    TAActionOverlayDirectionRight,
    TAActionOverlayDirectionUp,
    TAActionOverlayDirectionCenter
};

typedef NS_ENUM(NSInteger, TAActionOverlayAnimation){
    TAActionOverlayAnimationNone,
    TAActionOverlayAnimationBasic,
    TAActionOverlayAnimationCrossfade,
    TAActionOverlayAnimationSpring,
    TAActionOverlayAnimationFade,
    TAActionOverlayAnimationAlert
};

@interface TAActionOverlay : UIView

@property (nonatomic) UIEdgeInsets contentEdgeInsets;
@property (nonatomic) UIView *backgroundView;
@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic) BOOL tapToDissmiss;
@property (nonatomic, readonly) TAActionOverlayDirection direction;
@property (nonatomic, readonly) TAActionOverlayAnimation animation;
@property (nonatomic, copy) void (^dismissHandler)(BOOL finished);

- (instancetype)initWithContentView:(UIView *)contentView NS_DESIGNATED_INITIALIZER;

- (void)showFromDirection:(TAActionOverlayDirection)direction
                 animated:(BOOL)animated
               completion:(void (^)(BOOL finished))completion __deprecated_msg("Method deprecated. Use `showFromDirection:inView:animation:completion`");

- (void)dismissToDirection:(TAActionOverlayDirection)direction
                  animated:(BOOL)animated
                completion:(void (^)(BOOL finished))completion __deprecated_msg("Method deprecated. Use `dismissToDirection:animation:completion`");

- (void)showFromDirection:(TAActionOverlayDirection)direction
                   inView:(UIView *)view
                 animation:(TAActionOverlayAnimation)animation
               completion:(void (^)(BOOL finished))completion;

- (void)dismissToDirection:(TAActionOverlayDirection)direction
                 animation:(TAActionOverlayAnimation)animation
                completion:(void (^)(BOOL finished))completion;

@end

@protocol TAActionOverlayContentView <NSObject>
@optional
@property (nonatomic) BOOL animating;

@end

@interface UIView(TAActionOverlay)

- (TAActionOverlay *)actionOverlay;
- (TAActionOverlay *)showAsAlertOverlay;

@end
