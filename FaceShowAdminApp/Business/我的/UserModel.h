//
//  UserModel.h
//  SanKeApp
//
//  Created by niuzhaowang on 2017/1/18.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "GetUserInfoRequest.h"
#import "ClassListRequest.h"
#import "ClazsGetClazsRequest.h"

extern NSString * const kClassDidSelectNotification;
@interface UserModel : JSONModel
@property (nonatomic, copy) NSString<Optional> *userID;
@property (nonatomic, copy) NSString<Optional> *realName;
@property (nonatomic, copy) NSString<Optional> *mobilePhone;
@property (nonatomic, copy) NSString<Optional> *email;

@property (nonatomic, copy) NSString<Optional> *stageID;
@property (nonatomic, copy) NSString<Optional> *stageName;
@property (nonatomic, copy) NSString<Optional> *subjectID;
@property (nonatomic, copy) NSString<Optional> *subjectName;
@property (nonatomic, copy) NSString<Optional> *userStatus;
@property (nonatomic, copy) NSString<Optional> *ucnterID;
@property (nonatomic, copy) NSString<Optional> *sexID;
@property (nonatomic, copy) NSString<Optional> *sexName;
@property (nonatomic, copy) NSString<Optional> *school;
@property (nonatomic, copy) NSString<Optional> *avatarUrl;

@property (nonatomic, copy) NSString<Optional> *token;
@property (nonatomic, copy) NSString<Optional> *passport;

@property (nonatomic, strong) NSArray<Optional,ClassListRequestItem_clazsInfos> *clazsInfos;
@property (nonatomic, strong) ClassListRequestItem_clazsInfos<Optional> *currentClass;
@property (nonatomic, strong) ClazsGetClazsRequestItem_Data_ProjectInfo<Optional> *currentProject;
//
+ (UserModel *)modelFromUserInfo:(GetUserInfoRequestItem_Data *)userInfo;
- (void)updateFromUserInfo:(GetUserInfoRequestItem_Data *)userInfo;
@end
