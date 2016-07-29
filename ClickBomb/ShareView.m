//
//  ShareView.m
//  ClickBomb
//
//  Created by 武淅 段 on 16/7/28.
//  Copyright © 2016年 武淅 段. All rights reserved.
//

#import "ShareView.h"
#import "TAActionOverlay.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ShareView()

@property (nonatomic) NSString *currentLanguage;
@property (nonatomic) TAActionOverlay *overPlay;
@property (nonatomic, assign) BOOL isFail;

@end

@implementation ShareView

+ (instancetype)viewFromNib
{
    UINib *nib = [UINib nibWithNibName:@"ShareView" bundle:nil];
    ShareView *view = [[nib instantiateWithOwner:nil options:nil] lastObject];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    view.currentLanguage = currentLanguage;
    return view;
}

- (void)showWithFail
{
    _isFail = YES;
    _shareButton.hidden = YES;
    [_icon setImage:[UIImage imageNamed:@"fail"]];
    [_title setText:NSLocalizedString(@"loseTip", nil)];
    [_desc setText:NSLocalizedString(@"courage", nil)];
    [_nextButton setTitle:NSLocalizedString(@"retry", nil) forState:UIControlStateNormal];
    [self show];
    
}

- (void)showSuccessWIthRank:(NSInteger)rank
{
    _isFail = NO;
    _shareButton.hidden = NO;
    [_nextButton setTitle:NSLocalizedString(@"next", nil) forState:UIControlStateNormal];
    switch (rank) {
        case 3:
            [_title setText:NSLocalizedString(@"title1", nil)];
            [_desc setText:NSLocalizedString(@"desc1", nil)];
            [_icon setImage:[UIImage imageNamed:@"newton"]];
            break;
        case 4:
            [_title setText:NSLocalizedString(@"title2", nil)];
            [_desc setText:NSLocalizedString(@"desc2", nil)];
            [_icon setImage:[UIImage imageNamed:@"steven"]];
            break;
        case 5:
            [_title setText:NSLocalizedString(@"title3", nil)];
            [_desc setText:NSLocalizedString(@"desc3", nil)];
            [_icon setImage:[UIImage imageNamed:@"einstein"]];
            break;
        case 6:
            [_title setText:NSLocalizedString(@"title4", nil)];
            [_desc setText:NSLocalizedString(@"desc4", nil)];
            [_icon setImage:[UIImage imageNamed:@"god"]];
            break;

        default:
            break;
    }
    [self show];
}

- (void)show
{
    TAActionOverlay *overlay = [[TAActionOverlay alloc]initWithContentView:self];
    overlay.tapToDissmiss = NO;
    
    CGFloat hor = 20;
    self.frame = CGRectMake(hor, SCREEN_HEIGHT/2.0-self.frame.size.height/2.0, SCREEN_WIDTH-2*hor, self.frame.size.height);
    
    [overlay showFromDirection:TAActionOverlayDirectionCenter inView:nil animation:TAActionOverlayAnimationAlert completion:nil];
}



- (void)dismiss
{
    [[self actionOverlay] dismissToDirection:TAActionOverlayDirectionCenter animation:TAActionOverlayAnimationAlert completion:nil];
}

- (IBAction)share:(id)sender {
    
//    [self dismiss];
    if(_delegate && [_delegate respondsToSelector:@selector(didTapShareInView:)]){
        [_delegate didTapShareInView:self];
    }
    
}

- (IBAction)next:(id)sender {
    
    [self dismiss];
    if(_isFail){
        if(_delegate && [_delegate respondsToSelector:@selector(didTapOKInView:)]){
            [_delegate didTapOKInView:self];
        }
    }
    else{
        if(_delegate && [_delegate respondsToSelector:@selector(didTapNextInView:)]){
            [_delegate didTapNextInView:self];
        }
    }

}

@end
