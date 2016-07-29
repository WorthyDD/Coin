//
//  TAActionOverlay.m
//  TAActionOverlay
//
//  Created by Hale Chan on 15/3/24.
//  Copyright (c) 2015年 Tips4app Inc. All rights reserved.
//

#import "TAActionOverlay.h"
#import "CGGeometry+TAUIToolkit.h"

static NSTimeInterval TAActionOverlayAnimationDuration = 0.5;

@interface TAActionOverlay() {
    NSDate *_showDate;
}

@end

@implementation TAActionOverlay
@synthesize contentView=_contentView;

- (instancetype)initWithContentView:(UIView *)contentView
{
    self = [super initWithFrame:contentView.frame];
    if (self) {
        UIView *background = [[UIView alloc]initWithFrame:self.bounds];
        background.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        [self addSubview:background];
        _backgroundView = background;
        
        _contentView = contentView;
        _contentView.autoresizingMask = UIViewAutoresizingNone;
        [self addSubview:_contentView];
        
        _tapToDissmiss = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:self.bounds];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.autoresizingMask = UIViewAutoresizingNone;
    }
    return _contentView;
}

- (void)layoutSubviews
{
    _backgroundView.frame = self.bounds;
}

- (void)showFromDirection:(TAActionOverlayDirection)direction animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    TAActionOverlayAnimation animation = animated?TAActionOverlayAnimationBasic:TAActionOverlayAnimationNone;
    [self showFromDirection:direction inView:nil animation:animation completion:completion];
}

- (void)dismissToDirection:(TAActionOverlayDirection)direction animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    TAActionOverlayAnimation animation = animated ? _animation : TAActionOverlayAnimationNone;
    if (TAActionOverlayAnimationSpring == animation) {
        animation = TAActionOverlayAnimationBasic;
    }
    [self dismissToDirection:direction animation:animation completion:completion];
}

- (void)dismissToDirection:(TAActionOverlayDirection)direction
                 animation:(TAActionOverlayAnimation)animation
                completion:(void (^)(BOOL finished))completion
{
    CGRect bounds = self.bounds;
    
    CGRect destRect = bounds;
    destRect.size.width -= _contentEdgeInsets.left + _contentEdgeInsets.right;
    destRect.size.height -= _contentEdgeInsets.top + _contentEdgeInsets.bottom;
    destRect.size = [_contentView sizeThatFits:destRect.size];
    
    switch (direction) {
        case TAActionOverlayDirectionTop:
        {
            destRect.origin.x = (CGRectGetWidth(bounds) - CGRectGetWidth(destRect))/2.0;
            destRect.origin.y = -CGRectGetHeight(destRect);
        }
            break;
        case TAActionOverlayDirectionLeft:
        {
            destRect.origin.y = (CGRectGetHeight(bounds) - CGRectGetHeight(destRect))/2.0;
            destRect.origin.x = -CGRectGetWidth(destRect);
        }
            break;
        case TAActionOverlayDirectionRight:
        {
            destRect.origin.y = (CGRectGetHeight(bounds) - CGRectGetHeight(destRect))/2.0;
            destRect.origin.x = CGRectGetWidth(bounds);
        }
            break;
        case TAActionOverlayDirectionBottom:
        {
            destRect.origin.x = (CGRectGetWidth(bounds) - CGRectGetWidth(destRect))/2.0;
            destRect.origin.y = CGRectGetHeight(bounds);
        }
            break;
        case TAActionOverlayDirectionUp:
        {
           // destRect = _contentView.frame;
            destRect.origin.x = (CGRectGetWidth(bounds) - CGRectGetWidth(destRect))/2.0;
            destRect.origin.y = -CGRectGetHeight(destRect);

        }
            break;
        case TAActionOverlayDirectionCenter:{
            destRect = _contentView.frame;
        }
            break;
        default:
            break;
    }
    
    if ([_contentView isFirstResponder]) {
        [_contentView resignFirstResponder];
    }
    
    switch (animation) {
        case TAActionOverlayAnimationSpring:
        case TAActionOverlayAnimationBasic:{
            [UIView animateWithDuration:TAActionOverlayAnimationDuration animations:^{
                _backgroundView.alpha = 0.0;
                _contentView.frame = destRect;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                if (completion) {
                    completion(YES);
                }
                if (_dismissHandler) {
                    _dismissHandler(YES);
                }
            }];
        }
            break;
        case TAActionOverlayAnimationCrossfade:{
            [UIView animateWithDuration:TAActionOverlayAnimationDuration animations:^{
                _backgroundView.alpha = 0.0;
                _contentView.transform = CGAffineTransformMakeScale(8.0, 8.0);
                _contentView.alpha = 0.0;
            } completion:^(BOOL finished) {
                _contentView.transform = CGAffineTransformIdentity;
                _contentView.frame = destRect;
                _contentView.alpha = 1.0;
                [self removeFromSuperview];
                if (completion) {
                    completion(YES);
                }
                if (_dismissHandler) {
                    _dismissHandler(YES);
                }
            }];
        }
            break;
        case TAActionOverlayAnimationAlert:
        case TAActionOverlayAnimationFade:{
            [UIView animateWithDuration:TAActionOverlayAnimationDuration animations:^{
                _backgroundView.alpha = 0.0;
                _contentView.alpha = 0.0;
                _contentView.frame = destRect;
            } completion:^(BOOL finished) {
                _contentView.alpha = 1.0;
                [self removeFromSuperview];
                if (completion) {
                    completion(YES);
                }
                if (_dismissHandler) {
                    _dismissHandler(YES);
                }
            }];
        }
            break;
        default:{
            _backgroundView.alpha = 0.0;
            [self removeFromSuperview];
            _contentView.frame = destRect;
            if (completion) {
                completion(YES);
            }
            if (_dismissHandler) {
                _dismissHandler(YES);
            }
        }
            break;
    }
    
    _showDate = nil;
}

- (void)showFromDirection:(TAActionOverlayDirection)direction
                   inView:(UIView *)view
                 animation:(TAActionOverlayAnimation)animation
               completion:(void (^)(BOOL finished))completion
{
    if (view) {
        [self addToView:view];
    }
    else {
        [self addToCurrentWindow];
    }
    
    CGRect bounds = self.bounds;
    
    _backgroundView.alpha = 0.0;
    
    CGRect rect = bounds;
    rect.size.width -= _contentEdgeInsets.left + _contentEdgeInsets.right;
    rect.size.height -= _contentEdgeInsets.top + _contentEdgeInsets.bottom;
    rect.size = [_contentView sizeThatFits:rect.size];
    
    CGRect destRect = rect;
    
    switch (direction) {
        case TAActionOverlayDirectionTop:
        {
            rect.origin.x = (CGRectGetWidth(bounds) - CGRectGetWidth(rect))/2.0;
            rect.origin.y = -CGRectGetHeight(rect);
            
            destRect.origin.x = rect.origin.x;
            destRect.origin.y = _contentEdgeInsets.top;
        }
            break;
        case TAActionOverlayDirectionLeft:
        {
            rect.origin.y = (CGRectGetHeight(bounds) - CGRectGetHeight(rect))/2.0;
            rect.origin.x = -CGRectGetWidth(rect);
            
            destRect.origin.y = rect.origin.y;
            destRect.origin.x = _contentEdgeInsets.left;
        }
            break;
        case TAActionOverlayDirectionRight:
        {
            rect.origin.y = (CGRectGetHeight(bounds) - CGRectGetHeight(rect))/2.0;
            rect.origin.x = CGRectGetWidth(bounds);
            
            destRect.origin.y = rect.origin.y;
            destRect.origin.x = CGRectGetWidth(bounds) - _contentEdgeInsets.right - CGRectGetWidth(rect);
        }
            break;
        case TAActionOverlayDirectionBottom:
        {
            rect.origin.x = (CGRectGetWidth(bounds) - CGRectGetWidth(rect))/2.0;
            rect.origin.y = CGRectGetHeight(bounds);
            
            destRect.origin.x = rect.origin.x;
            destRect.origin.y = CGRectGetHeight(bounds) - _contentEdgeInsets.bottom - CGRectGetHeight(rect);
        }
            break;
        case TAActionOverlayDirectionUp:
        {
//            CGRectRefSetCenterUp(&rect, CGRectGetCenter(bounds));
//            CGRectRefSetCenterUp(&destRect, CGRectGetCenter(bounds));
            CGRectRefSetCenter(&rect, CGRectGetCenter(bounds));
            CGRectRefSetCenter(&destRect, CGRectGetCenter(bounds));
            destRect.origin.y -= 80;
        }
            break;
        case TAActionOverlayDirectionCenter:{
            CGRectRefSetCenter(&rect, CGRectGetCenter(bounds));
            CGRectRefSetCenter(&destRect, CGRectGetCenter(bounds));
        }
            break;
        default:
            break;
    }
    
    _contentView.frame = rect;
    
    switch (animation) {
        case TAActionOverlayAnimationBasic:{
            [UIView animateWithDuration:TAActionOverlayAnimationDuration animations:^{
                _backgroundView.alpha = 1.0;
                _contentView.frame = destRect;
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(YES);
                }
            }];
        }
            break;
        case TAActionOverlayAnimationCrossfade:{
            
            _contentView.alpha = 0.0;
            _contentView.frame = destRect;
            CGAffineTransform transform = CGAffineTransformMakeScale(0.1, 0.1);
            _contentView.transform = transform;
            
            [UIView animateWithDuration:TAActionOverlayAnimationDuration animations:^{
                _backgroundView.alpha = 1.0;
                _contentView.alpha = 1.0;
                _contentView.transform = CGAffineTransformIdentity;
                _contentView.frame = destRect;
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(YES);
                }
            }];
        }
            break;
        case TAActionOverlayAnimationSpring:{
            [UIView animateWithDuration:TAActionOverlayAnimationDuration delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:2.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _backgroundView.alpha = 1.0;
                _contentView.frame = destRect;
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(YES);
                }
            }];
        }
            break;
        case TAActionOverlayAnimationFade:{
            _contentView.alpha = 0.0;
            [UIView animateWithDuration:TAActionOverlayAnimationDuration animations:^{
                _backgroundView.alpha = 1.0;
                _contentView.alpha = 1.0;
                _contentView.frame = destRect;
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(YES);
                }
            }];
        }
            break;
        case TAActionOverlayAnimationAlert: {
            _contentView.alpha = 0.5;
            _contentView.transform = CGAffineTransformMakeScale(0.5, 0.5);
            [UIView animateWithDuration:TAActionOverlayAnimationDuration delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _backgroundView.alpha = 1.0;
                _contentView.transform = CGAffineTransformIdentity;
                _contentView.frame = destRect;
                _contentView.alpha = 1.0;
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(YES);
                }
            }];
        }
            break;
        default:{
            _contentView.frame = destRect;
            _backgroundView.alpha = 1.0;
            if (completion) {
                completion(YES);
            }
        }
            break;
    }
    
    _direction = direction;
    _showDate = [NSDate date];
    _animation = animation;
}

- (void)addToCurrentWindow
{
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    
    if (!currentWindow) {
        NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
        
        for (UIWindow *window in frontToBackWindows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                currentWindow = window;
                break;
            }
        }
    }
    
    if (self.superview != currentWindow) {
        [self addToView:currentWindow];
    }
}

- (void)addToView:(UIView *)superview
{
    if (self.superview) {
        [self removeFromSuperview];
    }
    [superview addSubview:self];
    [superview bringSubviewToFront:self];
    self.frame = superview.bounds;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self layoutIfNeeded];
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_tapToDissmiss && _showDate && [[NSDate date] timeIntervalSinceDate:_showDate] >= TAActionOverlayAnimationDuration) {
        UITouch *touch = [touches anyObject];
        CGPoint p = [touch locationInView:_contentView];
        if (!CGRectContainsPoint(_contentView.bounds, p)) {
            [self dismissToDirection:_direction animation:TAActionOverlayAnimationAlert completion:nil];
        }
    }
}

@end

@implementation UIView (TAActionOverlay)

- (TAActionOverlay *)actionOverlay
{
    UIView *view = self;
    while (view) {
        if ([view isKindOfClass:[TAActionOverlay class]]) {
            break;
        }
        view = view.superview;
    }
    return (TAActionOverlay *)view;
}

- (TAActionOverlay *)showAsAlertOverlay
{
    TAActionOverlay *overlay = [[TAActionOverlay alloc]initWithContentView:self];
    [overlay showFromDirection:TAActionOverlayDirectionCenter inView:nil animation:TAActionOverlayAnimationFade completion:nil];
    return overlay;
}

@end
