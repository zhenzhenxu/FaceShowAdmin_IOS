//
//  AppDelegateHelper.h
//  AppDelegateTest
//
//  Created by niuzhaowang on 2016/9/26.
//  Copyright © 2016年 niuzhaowang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegateHelper : NSObject

- (instancetype)initWithWindow:(UIWindow *)window;
@property (nonatomic, strong, readonly) UIWindow *window;

// 启动的根视图控制器
- (UIViewController *)rootViewController;

// 登录成功/失败的UI处理
- (void)handleLoginSuccess;
- (void)handleLogoutSuccess;

// class selection
- (void)handleClassChange;


@end
