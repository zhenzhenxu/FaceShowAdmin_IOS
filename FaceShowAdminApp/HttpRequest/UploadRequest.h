//
//  UploadRequest.h
//  YanXiuStudentApp
//
//  Created by Lei Cai on 7/2/15.
//  Copyright (c) 2015 yanxiu. All rights reserved.
//

#import "HttpBaseRequest.h"
#import <ASIFormDataRequest.h>
@interface UploadRequest : HttpBaseRequest
- (ASIFormDataRequest *)request;
@end
