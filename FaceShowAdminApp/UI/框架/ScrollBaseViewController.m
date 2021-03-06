//
//  ScrollBaseViewController.m
//  YanXiuStudentApp
//
//  Created by niuzhaowang on 2017/4/27.
//  Copyright © 2017年 yanxiu.com. All rights reserved.
//

#import "ScrollBaseViewController.h"

@implementation ScrollBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bottomHeightWhenKeyboardShows = -1;
    [self setupBaseUI];
    [self setupObservers];
    AdjustsScrollViewInsetNever(self, self.scrollView);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupBaseUI {
    self.scrollView = [[UIScrollView alloc]init];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.contentView = [[UIView alloc]init];
    [self.scrollView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
        make.width.mas_equalTo(self.scrollView.mas_width);
//        make.height.mas_equalTo(self.scrollView.mas_height);
    }];
}

- (void)setupObservers {
    WEAK_SELF
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:UIKeyboardWillChangeFrameNotification object:nil]subscribeNext:^(id x) {
        STRONG_SELF
        NSNotification *noti = (NSNotification *)x;
        NSDictionary *dic = noti.userInfo;
        NSValue *keyboardFrameValue = [dic valueForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardFrame = keyboardFrameValue.CGRectValue;
        NSNumber *duration = [dic valueForKey:UIKeyboardAnimationDurationUserInfoKey];
        [UIView animateWithDuration:duration.floatValue animations:^{
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, [UIScreen mainScreen].bounds.size.height-keyboardFrame.origin.y, 0);
            if (keyboardFrame.origin.y < SCREEN_HEIGHT && self.bottomHeightWhenKeyboardShows>0) {
                [self.scrollView scrollRectToVisible:CGRectMake(0, self.view.height-self.bottomHeightWhenKeyboardShows, 1, 1) animated:NO];
            }
        }];
    }];
}

@end
