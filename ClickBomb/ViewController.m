//
//  ViewController.m
//  ClickBomb
//
//  Created by 武淅 段 on 16/7/26.
//  Copyright © 2016年 武淅 段. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Geometry.h"
#import "UIColor+TAToolkit.h"
#import <Social/Social.h>
#import "Firebase.h"
#import "ShareView.h"

@import GoogleMobileAds;

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define CARD_COLOR [UIColor colorWithRGB:0xfd6e37]
/**
 *      应用 ID：ca-app-pub-1802974368681645~2531606618
        广告单元 ID：ca-app-pub-1802974368681645/2396849012
 *
 */

@interface ViewController ()<GADBannerViewDelegate, ShareDelegate>

@property (nonatomic) NSMutableArray *cards;
@property (nonatomic, assign) NSInteger rank;  //2,3,4,5
@property (nonatomic, assign) NSInteger seconds;
@property (nonatomic) UILabel *tip;
@property (nonatomic, assign) NSInteger lastOpenIndex;
@property (nonatomic, assign) NSInteger maxSecond;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic) UILabel *secondsLabel;
@property (nonatomic) NSString *currentLanguage; //zh-Hans   简体中文  en 英语
@property (nonatomic) GADBannerView *adBannerView;
@property (nonatomic, assign) NSInteger chances;        //翻牌的机会
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _rank = 3;
    _maxSecond = 10;
    _fontSize = 40.0;
    _chances = 1;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 20, SCREEN_WIDTH-30, 60)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor blackColor]];
    [label setFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:20.0]];
    [label setText:@""];
    label.numberOfLines = 0;
    [self.view addSubview:label];
    _tip = label;
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0,0,100,28)];
    label1.center = CGPointMake(SCREEN_WIDTH/2, 100);
    [label1 setTextAlignment:NSTextAlignmentCenter];
    [label1 setTextColor:[UIColor whiteColor]];
    [label1 setBackgroundColor:[UIColor colorWithRGB:0xe7683c]];
    [label1 setClipsToBounds:YES];
    label1.layer.cornerRadius = 12;
    [label1 setFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:28.0]];
    [label1 setText:@""];
    label1.numberOfLines = 0;
    [self.view addSubview:label1];
    _secondsLabel = label1;
    
    GADBannerView *banner = [[GADBannerView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 50)];
//    [banner setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:banner];
    banner.adUnitID = @"ca-app-pub-1802974368681645/2396849012";
    banner.rootViewController = self;
    banner.delegate = self;
    
    GADRequest *request = [GADRequest request];
//    request.testDevices = @[ @"4732a37ad6fec36b78631906c0eb7b25" ];
    [banner loadRequest:request];
    _adBannerView = banner;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    NSLog(@"\n%@\n", currentLanguage);
    _currentLanguage = currentLanguage;
    
    [self initCards];
    [self startGame];
    
}

- (void) initCards
{
    for(UIButton *card in _cards){
        [card removeFromSuperview];
    }
    _cards = [NSMutableArray new];
    
    CGFloat width = SCREEN_WIDTH/_rank-20;
    for(int i = 0; i < _rank*_rank;i++){
        UIButton *card = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, width, width)];
//        [card setText:[NSString stringWithFormat:@"%d", i+1]];
        [card setTitle:@"" forState:UIControlStateNormal];
        [card.titleLabel setFont:[UIFont fontWithName:@"ChalkboardSE-Bold" size:_fontSize]];
        [card setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [card setBackgroundColor:[UIColor colorWithRGB:0xe7683c]];
        card.layer.cornerRadius = width/2;
        card.layer.borderColor = [UIColor colorWithRGB:0x9a2812].CGColor;
        card.layer.borderWidth = 2;
        card.layer.shadowColor = [UIColor colorWithRGB:0x333333].CGColor;
        card.layer.shadowOffset = CGSizeMake(0, 3);
        card.layer.shadowRadius = 5;
        card.center = self.view.center;
        [self.view addSubview:card];
        [_cards addObject:card];
    }
    
}

- (void) startGame
{
    int nums[200];
    for(int i = 1; i <= _rank*_rank; i++){
        nums[i-1] = i;
    }
    
    for(NSInteger j = _rank*_rank-1; j >=0; j--){
        NSInteger index = j>0? arc4random()%j : 0;
        int num = nums[index];
        nums[index] = nums[j];
        nums[j] = num;
        
        UIButton *card = _cards[j];
        [card setTitle:[NSString stringWithFormat:@"%d", num] forState:UIControlStateNormal];
        card.tag = num;
        card.userInteractionEnabled = NO;
        [card addTarget:self action:@selector(didSelectCard:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat width = SCREEN_WIDTH/_rank;
        NSInteger row = j/_rank;
        NSInteger col = j%_rank;
        CGFloat x = 10+row*width+card.width/2;
        CGFloat y = 160+width*col+card.width/2;
        [UIView animateWithDuration:0.3 animations:^{
            card.center = CGPointMake(x, y);
        }];
    }
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(caculteTime:) userInfo:nil repeats:YES];
    [timer fire];
}

- (void) caculteTime: (NSTimer *)timer
{
    _seconds++;
    
    NSMutableString *str = [NSMutableString stringWithString:NSLocalizedString(@"caculateTip", nil)];
    //[str stringByAppendingString:NSLocalizedString(@"leftSecond", nil)];
    //[str stringByAppendingString:[NSString stringWithFormat:@"%ld", _maxSecond-_seconds]];
    //[str stringByAppendingString:NSLocalizedString(@"second", nil)];
    
    [_tip setText:str];
    _secondsLabel.hidden = NO;
    [_secondsLabel setText:[NSString stringWithFormat:@"%lds", _maxSecond-_seconds]];
    if(_seconds >= _maxSecond){
        _secondsLabel.hidden = YES;
        [_tip setText: NSLocalizedString(@"playTip", nil)];
        for(UIButton *card in _cards){
            card.userInteractionEnabled = YES;
            [UIView animateWithDuration:0.3 animations:^{
                card.layer.transform = CATransform3DMakeRotation(M_PI_2, 1, 0, 0);
            }completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3 animations:^{
                    [card setTitle:@"" forState:UIControlStateNormal];
                    [card setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
                    card.layer.transform = CATransform3DIdentity;
                }completion:^(BOOL finished) {
                    
                }];
            }];
        }
        _seconds = 0;
        [timer invalidate];
        timer = nil;
    }
}

- (void) didSelectCard : (UIButton *)sender
{
    if(!sender.selected){
        sender.selected = !sender.selected;

        __weak typeof(self) weak_self = self;
        [UIView animateWithDuration:0.3 animations:^{
            sender.layer.transform = CATransform3DMakeRotation(M_PI_2, 1, 0, 0);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                [sender setTitle:[NSString stringWithFormat:@"%ld", sender.tag] forState:UIControlStateNormal];
                [sender setImage:nil forState:UIControlStateNormal];
                sender.layer.transform = CATransform3DIdentity;
            }completion:^(BOOL finished) {
                if(sender.tag - _lastOpenIndex != 1){
                    
                    _chances--;
                    if(_chances >= 0 ){
                        
                        [UIView animateWithDuration:0.3 animations:^{
                            sender.layer.transform = CATransform3DMakeRotation(M_PI_2, 1, 0, 0);
                        }completion:^(BOOL finished) {
                            [UIView animateWithDuration:0.3 animations:^{
//                                sender.layer.transform = CATransform3DMakeRotation(M_PI_2, 1, 0, 0);
                                sender.selected = !sender.selected;
                                [sender setTitle:@"" forState:UIControlStateNormal];
                                [sender setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
                                sender.layer.transform = CATransform3DIdentity;
                            }];
                        }];
                        return;
                    }
                    
                    
                    //错误
                    /*UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"loseTip", nil) message:NSLocalizedString(@"courage", nil) preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *done = [UIAlertAction actionWithTitle:NSLocalizedString(@"retry", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        weak_self.lastOpenIndex = 0;
                        switch (_rank) {
                            case 3:
                                _chances = 1;
                                break;
                            case 4:
                                _chances = 5;
                                break;
                            case 5:
                                _chances = 10;
                                break;
                            case 6:
                                _chances = 16;
                            default:
                                _chances = 20;
                                break;
                        }
                        [weak_self initCards];
                        [weak_self startGame];
                    }];
                   // UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"cancle" style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:done];
                    //[alert addAction:cancle];
                    [weak_self presentViewController:alert animated:YES completion:nil];*/
                    
                    
                    ShareView *shareView = [ShareView viewFromNib];
                    shareView.delegate = self;
                    [shareView showWithFail];
                }
                else{
                    weak_self.lastOpenIndex = sender.tag;
                    
                    //成功
                    if(sender.tag == weak_self.rank*weak_self.rank){
                        
                        /*UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"congradulation", nil)message:NSLocalizedString(@"successTip", nil) preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *cancle = [UIAlertAction actionWithTitle:NSLocalizedString(@"next", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            
                            //next level
                            [weak_self nextLevel];
                            
                        }];
                        UIAlertAction *share = [UIAlertAction actionWithTitle:NSLocalizedString(@"share", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            
                            //next level
                            [weak_self share];
                            
                        }];
                        [alert addAction:cancle];
                        [alert addAction:share];
                        [weak_self presentViewController:alert animated:YES completion:nil];*/
                        
                        ShareView *share = [ShareView viewFromNib];
                        share.delegate = self;
                        [share showSuccessWIthRank:weak_self.rank];
                    }
                }
            }];
        }];
    }
}

- (void) nextLevel
{
    _rank ++;
    _lastOpenIndex = 0;
    switch (_rank) {
        case 3:
            _maxSecond = 10;
            _fontSize = 40.0;
            _chances = 1;
            break;
        case 4:
            _maxSecond = 60;
            _fontSize = 32.0;
            _chances = 5;
            break;
        case 5:
            _maxSecond = 300;
            _fontSize = 26.0;
            _chances = 10;
            break;
        case 6:
            _maxSecond = 600;
            _fontSize = 22.0;
            _chances = 16;
        default:
            _maxSecond = 1200;
            _fontSize = 20.0;
            _chances = 20;
            break;
    }
    
    [self initCards];
    [self startGame];
}

- (void) share
{
    
    NSString *shareMessage;
    if([_currentLanguage containsString:@"zh-Hans"]){
        shareMessage = [NSString stringWithFormat:@"我在%ld秒内记住了%ld个数的位置, 不服来挑战\nThe Strongest Memory-超强记忆", _maxSecond, _rank*_rank];
    }
    else{
        shareMessage = [NSString stringWithFormat:@"I have remembered %ld numbers's order within %ld seconds, would you like to challenge me?\n-The Strongest Memory-超强记忆", _maxSecond, _rank*_rank];
    }
    UIImage *im = [UIImage imageNamed:@"tu"];
    
    UIActivityViewController *activeViewController = [[UIActivityViewController alloc]initWithActivityItems:@[shareMessage, im] applicationActivities:nil];
    //不显示哪些分享平台(具体支持那些平台，可以查看Xcode的api)
    activeViewController.excludedActivityTypes = @[UIActivityTypeAirDrop,UIActivityTypeCopyToPasteboard,UIActivityTypeAddToReadingList];
    [self presentViewController:activeViewController animated:YES completion:nil];
    //分享结果回调方法
//    UIActivityViewControllerCompletionHandler myblock = ^(NSString *type,BOOL completed){
//        NSLog(@"%d %@",completed,type);
//    };
    
    __weak typeof(self) weak_self = self;
    activeViewController.completionWithItemsHandler = ^(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
        NSLog(@"%d %@,%@",completed,activityType, activityError);
        [weak_self nextLevel];
        
    };
//    activeViewController.completionHandler = myblock;
}

#pragma GADBanner

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    NSLog(@"\n\nreceive ad");
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"\n\nreceive ad error--> %@", error);
}


#pragma mark - share

- (void)didTapShareInView:(ShareView *)view
{
    UIGraphicsBeginImageContext(CGSizeMake(view.width, view.height-60)); //currentView 当前的view
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);  //保存到相册中
    UIActivityViewController *activeViewController = [[UIActivityViewController alloc]initWithActivityItems:@[viewImage] applicationActivities:nil];
    //不显示哪些分享平台(具体支持那些平台，可以查看Xcode的api)
    activeViewController.excludedActivityTypes = @[UIActivityTypeAirDrop,UIActivityTypeCopyToPasteboard,UIActivityTypeAddToReadingList];
    [self presentViewController:activeViewController animated:YES completion:nil];
    //分享结果回调方法
    //    UIActivityViewControllerCompletionHandler myblock = ^(NSString *type,BOOL completed){
    //        NSLog(@"%d %@",completed,type);
    //    };
    
    __weak typeof(self) weak_self = self;
    activeViewController.completionWithItemsHandler = ^(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
        NSLog(@"%d %@,%@",completed,activityType, activityError);
        [weak_self nextLevel];
        
    };
    [view dismiss];
}

- (void)didTapNextInView:(ShareView *)view
{
    [self nextLevel];
}

- (void)didTapOKInView:(ShareView *)view
{
    _lastOpenIndex = 0;
    switch (_rank) {
        case 3:
            _chances = 1;
            break;
        case 4:
            _chances = 5;
            break;
        case 5:
            _chances = 10;
            break;
        case 6:
            _chances = 16;
        default:
            _chances = 20;
            break;
    }
    [self initCards];
    [self startGame];

}

@end
