//
//  ShareView.h
//  ClickBomb
//
//  Created by 武淅 段 on 16/7/28.
//  Copyright © 2016年 武淅 段. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShareDelegate;

@interface ShareView : UIView


@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *desc;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (nonatomic, weak) id<ShareDelegate> delegate;

+ (instancetype) viewFromNib;
- (void) showWithFail;
- (void) showSuccessWIthRank : (NSInteger)rank;
- (void) dismiss;
@end

@protocol ShareDelegate <NSObject>

- (void)didTapShareInView : (ShareView *)view;
- (void)didTapNextInView : (ShareView *)view;
- (void)didTapOKInView : (ShareView *)view;

@end