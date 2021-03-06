//
//  AppDelegate.m
//  FaceShowAdminApp
//
//  Created by niuzhaowang on 2017/10/25.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegateHelper.h"

@interface AppDelegate ()
@property (nonatomic, strong) AppDelegateHelper *appDelegateHelper;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GlobalUtils setupCore];
    // Talking Data统计
    [TalkingData setExceptionReportEnabled:YES];
    [TalkingData setSignalReportEnabled:YES];
    [TalkingData sessionStarted:[ConfigManager sharedInstance].TalkingDataAppID withChannelId:[ConfigManager sharedInstance].channel];
    [self registerNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.appDelegateHelper = [[AppDelegateHelper alloc]initWithWindow:self.window];
    self.window.rootViewController = [self.appDelegateHelper rootViewController];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)registerNotifications {
    WEAK_SELF
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kUserDidLoginNotification object:nil]subscribeNext:^(id x) {
        STRONG_SELF
        [self.appDelegateHelper handleLoginSuccess];
    }];
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kUserDidLogoutNotification object:nil]subscribeNext:^(id x) {
        STRONG_SELF
        [self.appDelegateHelper handleLogoutSuccess];
    }];
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kClassDidSelectNotification object:nil]subscribeNext:^(id x) {
        STRONG_SELF
        [self.appDelegateHelper handleClassChange];
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [GlobalUtils clearCore];
}


@end
