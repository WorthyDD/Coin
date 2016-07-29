//
//  CGGeometry+TAUIToolkit
//  TAToolkit
//
//  Created by Hale Chan on 14-6-30.
//  Copyright (c) 2014年 Tips4app Inc. All rights reserved.
//

#ifndef TAToolkit_CGGeometry_TAUIToolkit_h
#define TAToolkit_CGGeometry_TAUIToolkit_h

#include <CoreGraphics/CoreGraphics.h>

#pragma mark - CGRectRef Setters

#ifdef __cplusplus 
extern "C" {
#endif

static inline void CGRectRefSetX(CGRect *ref, CGFloat x)
{
    ref->origin.x = x;
}

static inline void CGRectRefSetY(CGRect *ref, CGFloat y)
{
    ref->origin.y = y;
}

static inline void CGRectRefSetMaxX(CGRect *ref, CGFloat x)
{
    ref->origin.x = x - ref->size.width;
}

static inline void CGRectRefSetMaxY(CGRect *ref, CGFloat y)
{
    ref->origin.y = y - ref->size.height;
}

static inline void CGRectRefSetWidth(CGRect *ref, CGFloat width)
{
    ref->size.width = width;
}

static inline void CGRectRefSetHeight(CGRect *ref, CGFloat height)
{
    ref->size.height = height;
}

static inline void CGRectRefSetCenterX(CGRect *ref, CGFloat centerX)
{
    ref->origin.x = centerX - ref->size.width/2.0;
}

static inline void CGRectRefSetCenterY(CGRect *ref, CGFloat centerY)
{
    ref->origin.y = centerY - ref->size.height/2.0;
}

static inline void CGRectRefSetCenter(CGRect *ref, CGPoint center)
{
    ref->origin.x = center.x - ref->size.width/2.0;
    ref->origin.y = center.y - ref->size.height/2.0;
}

static inline void CGRectRefSetCenterUp(CGRect *ref, CGPoint center)
{
    ref->origin.x = center.x - ref->size.width/2.0;
    ref->origin.y = center.y - ref->size.height/2.0 - 40;
}
    
#pragma mark - CGRect Setters

static inline CGRect CGRectSetX(CGRect rect, CGFloat x)
{
    CGRect otherRect = rect;
    otherRect.origin.x = x;
    return otherRect;
}

static inline CGRect CGRectSetY(CGRect rect, CGFloat y)
{
    CGRect otherRect = rect;
    otherRect.origin.y = y;
    return otherRect;
}

static inline CGRect CGRectSetMaxX(CGRect rect, CGFloat x)
{
    CGRect otherRect = rect;
    otherRect.origin.x = x - rect.size.width;
    return otherRect;
}

static inline CGRect CGRectSetMaxY(CGRect rect, CGFloat y)
{
    CGRect otherRect = rect;
    otherRect.origin.y = y - rect.size.height;
    return otherRect;
}

static inline CGRect CGRectSetWidth(CGRect rect, CGFloat width)
{
    CGRect otherRect = rect;
    rect.size.width = width;
    return otherRect;
}

static inline CGRect CGRectSetHeight(CGRect rect, CGFloat height)
{
    CGRect otherRect = rect;
    rect.size.height = height;
    return otherRect;
}

static inline CGRect CGRectSetCenterX(CGRect rect, CGFloat centerX)
{
    CGRect otherRect = rect;
    otherRect.origin.x = centerX - rect.size.width/2.0;
    return otherRect;
}

static inline CGRect CGRectSetCenterY(CGRect rect, CGFloat centerY)
{
    CGRect otherRect = rect;
    otherRect.origin.y = centerY - rect.size.height/2.0;
    return otherRect;
}

static inline CGRect CGRectSetCenter(CGRect rect, CGPoint center)
{
    CGRect otherRect = rect;
    otherRect.origin.x = center.x - rect.size.width/2.0;
    otherRect.origin.y = center.y - rect.size.height/2.0;
    return otherRect;
}

#pragma mark CGRect Getters

static inline CGPoint CGRectGetCenter(CGRect rect)
{
    return (CGPoint){.x = (CGFloat)(rect.origin.x + rect.size.width/2.0), .y = (CGFloat)(rect.origin.y + rect.size.height/2.0)};
}

static inline CGFloat CGRectGetCenterX(CGRect rect)
{
    return (rect.origin.x + rect.size.width/2.0);
}

static inline CGFloat CGRectGetCenterY(CGRect rect)
{
    return (rect.origin.y + rect.size.height/2.0);
}

#ifdef __cplusplus 
}
#endif

#endif
