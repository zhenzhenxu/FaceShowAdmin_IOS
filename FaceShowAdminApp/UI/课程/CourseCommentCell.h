//
//  CourseCommentCell.h
//  FaceShowApp
//
//  Created by niuzhaowang on 2017/9/15.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetCourseCommentRequest.h"

@interface CourseCommentCell : UITableViewCell
@property (nonatomic, strong) GetCourseCommentRequestItem_element *item;
@property (nonatomic, strong) NSString *currentTime;
@property (nonatomic, assign) BOOL bottomLineHidden;
@property (nonatomic, strong) void(^menuBlock)(UIButton *sender);
@end
