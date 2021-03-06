//
//  ClassMomentViewController.m
//  FaceShowApp
//
//  Created by niuzhaowang on 2017/9/13.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import "ClassMomentViewController.h"
#import "UITableView+TemplateLayoutHeaderView.h"
#import "ClassMomentHeaderView.h"
#import "ClassMomentCell.h"
#import "ClassMomentTableHeaderView.h"
#import "ClassMomentFooterView.h"
#import "PublishMomentViewController.h"
#import "ClassMomentFloatingView.h"
#import "YXImagePickerController.h"
#import "CommentInputView.h"
#import "ClassMomentListFetcher.h"
#import "ClassMomentClickLikeRequest.h"
#import "ClassMomentCommentRequest.h"
#import "AlertView.h"
#import "FDActionSheetView.h"
#import "ClassMomentDeleteRequest.h"
#import "YXDrawerController.h"
#import "ReportViewController.h"

@interface ClassMomentViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) ClassMomentTableHeaderView *headerView;
@property (nonatomic, strong) ClassMomentFloatingView *floatingView;
@property (nonatomic, strong) YXImagePickerController *imagePickerController;
@property (nonatomic, strong) CommentInputView *inputView;
@property (nonatomic, strong) AlertView *alertView;


@property (nonatomic, assign) NSInteger commtentInteger;

@property (nonatomic, strong) ClassMomentClickLikeRequest *clickLikeRequest;
@property (nonatomic, strong) ClassMomentCommentRequest *commentRequest;
@property (nonatomic, strong) ClassMomentDeleteRequest *deleteRequest;
@end

@implementation ClassMomentViewController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DDLogDebug(@"release========>>%@",[self class]);
}
- (void)viewDidLoad {
    ClassMomentListFetcher *fetcher = [[ClassMomentListFetcher alloc] init];
    fetcher.pagesize = 20;
    fetcher.clazsId = [UserManager sharedInstance].userModel.currentClass.clazsId;
    self.dataFetcher = fetcher;
    self.bIsGroupedTableViewStyle = YES;
    [super viewDidLoad];
    self.navigationItem.title = @"班级圈";
    [self setupUI];
    [self setupObservers];
//    self.edgesForExtendedLayout = UIRectEdgeAll;

}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.floatingView hiddenViewAnimate:NO];
}
#pragma mark - set & get
- (YXImagePickerController *)imagePickerController
{
    if (_imagePickerController == nil) {
        _imagePickerController = [[YXImagePickerController alloc] init];
    }
    return _imagePickerController;
}
- (ClassMomentFloatingView *)floatingView {
    if (_floatingView == nil) {
        _floatingView = [[ClassMomentFloatingView alloc] init];
    }
    return _floatingView;
}
- (void)setCommtentInteger:(NSInteger)commtentInteger {
    _commtentInteger = commtentInteger;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - setupUI
- (void)setupUI {
    self.emptyView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"ebeff2"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[ClassMomentHeaderView class] forHeaderFooterViewReuseIdentifier:@"ClassMomentHeaderView"];
    [self.tableView registerClass:[ClassMomentCell class] forCellReuseIdentifier:@"ClassMomentCell"];
    [self.tableView registerClass:[ClassMomentFooterView class] forHeaderFooterViewReuseIdentifier:@"ClassMomentFooterView"];
    self.headerView = [[ClassMomentTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 157.0f)];
    self.headerView.hidden = YES;
    self.tableView.tableHeaderView = self.headerView;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
     WEAK_SELF
    [[tapGestureRecognizer rac_gestureSignal] subscribeNext:^(UITapGestureRecognizer *x) {
        STRONG_SELF
        [self hiddenInputTextView];
    }];
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    
    [self nyx_setupLeftWithImageName:@"抽屉列表按钮正常态" highlightImageName:@"抽屉列表按钮点击态" action:^{
        STRONG_SELF
        [YXDrawerController showDrawer];
    }];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30.0f, 30.0f);
    [rightButton setImage:[UIImage imageNamed:@"上传内容图标正常态"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"上传内容图标点击态"] forState:UIControlStateHighlighted];

    [[rightButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        STRONG_SELF
        [TalkingData trackEvent:@"发布班级圈"];
        [self showAlertView];
    }];
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
    gestureRecognizer.minimumPressDuration = 1.0f;
    [[gestureRecognizer rac_gestureSignal] subscribeNext:^(UILongPressGestureRecognizer *x) {
        if (x.state == UIGestureRecognizerStateBegan) {
            [TalkingData trackEvent:@"发布班级圈"];
            [self presentNextPublishViewController:nil];
        }
    }];
    [rightButton addGestureRecognizer:gestureRecognizer];
    [self nyx_setupRightWithCustomView:rightButton];
    
    self.inputView = [[CommentInputView alloc]init];
    self.inputView.isChangeBool = YES;
    self.inputView.textView.returnKeyType = UIReturnKeySend;
    self.inputView.completeBlock = ^(NSString *text) {
        STRONG_SELF
        if (text.length != 0) {
            [self requstForPublishComment:text];            
        }
    };
    self.inputView.textHeightChangeBlock = ^(CGFloat textHeight) {
        STRONG_SELF
        [self.inputView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(textHeight + 12.0f);
        }];
    };
    [self.view addSubview:self.inputView];
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(45.0f);
        make.bottom.mas_equalTo(100.0f);
    }];

}
- (void)hiddenInputTextView {
    if (self.dataArray.count > self.commtentInteger) {
        ClassMomentListRequestItem_Data_Moment *moment = self.dataArray[self.commtentInteger];
        moment.draftModel = self.inputView.textView.text;
    }
    self.inputView.textString = nil;
    [self.inputView.textView resignFirstResponder];
    if (self.floatingView.superview != nil) {
        [self.floatingView hiddenViewAnimate:NO];
    }
}
- (void)stopAnimation {
    [super stopAnimation];
    [self.headerView reload];
    self.headerView.hidden = NO;
}
- (void)showAlertView {
    FDActionSheetView *actionSheetView = [[FDActionSheetView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    actionSheetView.titleArray = @[@{@"title":@"拍照"},
                                   @{@"title":@"相册"}];
    self.alertView = [[AlertView alloc]init];
    self.alertView.backgroundColor = [UIColor clearColor];
    self.alertView.hideWhenMaskClicked = YES;
    self.alertView.contentView = actionSheetView;
    WEAK_SELF
    [self.alertView setHideBlock:^(AlertView *view) {
        STRONG_SELF
        [UIView animateWithDuration:0.3 animations:^{
            [actionSheetView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(view.mas_left);
                make.right.equalTo(view.mas_right);
                make.top.equalTo(view.mas_bottom);
                make.height.mas_offset(155.0f);
            }];
            [view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }];
    [self.alertView showWithLayout:^(AlertView *view) {
        STRONG_SELF
        [actionSheetView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view.mas_left);
            make.right.equalTo(view.mas_right);
            make.top.equalTo(view.mas_bottom);
            make.height.mas_offset(155.0f );
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                [actionSheetView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(view.mas_left);
                    make.right.equalTo(view.mas_right);
                    if (@available(iOS 11.0, *)) {
                        make.bottom.mas_equalTo(view.mas_safeAreaLayoutGuideBottom);
                    } else {
                        make.bottom.mas_equalTo(0);
                    }
                    make.height.mas_offset(155.0f);
                }];
                [view layoutIfNeeded];
            } completion:^(BOOL finished) {
                
            }];
        });
    }];
    actionSheetView.actionSheetBlock = ^(NSInteger integer) {
        STRONG_SELF
        if (integer == 1) {
            [self.imagePickerController pickImageWithSourceType:UIImagePickerControllerSourceTypeCamera
                                             rootViewController:self completion:^(UIImage *selectedImage) {
                                                 STRONG_SELF
                                                 [self presentNextPublishViewController:selectedImage];
                                             }];
            
        }else if (integer == 2) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imagePickerController pickImageWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary rootViewController:[self nyx_visibleViewController] completion:^(UIImage *selectedImage) {
                    STRONG_SELF
                    [self presentNextPublishViewController:selectedImage];
                }];
            });
            
        }
        [self.alertView hide];
    };
}
- (void)presentNextPublishViewController:(UIImage *)image {
    PublishMomentViewController *VC = [[PublishMomentViewController alloc] init];
    if (image != nil) {
        VC.imageArray = @[image];
    }
    WEAK_SELF
    VC.publishMomentDataBlock = ^(ClassMomentListRequestItem_Data_Moment *moment) {
        STRONG_SELF
        if (moment != nil) {
            self.emptyView.hidden = YES;
            self.errorView.hidden = YES;
            [self.dataArray insertObject:moment atIndex:0];
            [self.tableView reloadData];
        }

    };
    FSNavigationController *nav = [[FSNavigationController alloc] initWithRootViewController:VC];
    [self presentViewController:nav animated:YES completion:^{
        
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
            [self.inputView mas_updateConstraints:^(MASConstraintMaker *make) {
                if (SCREEN_HEIGHT == keyboardFrame.origin.y) {
                    make.bottom.mas_equalTo(-(SCREEN_HEIGHT -keyboardFrame.origin.y) + 100.0f);
                }else {
                    make.bottom.mas_equalTo(-(SCREEN_HEIGHT -keyboardFrame.origin.y) + 50.0f);
                }
            }];
            [self.view layoutIfNeeded];
        }];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ClassMomentListRequestItem_Data_Moment *moment = self.dataArray[section];
    return moment.comments.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ClassMomentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClassMomentCell" forIndexPath:indexPath];
    ClassMomentListRequestItem_Data_Moment *moment = self.dataArray[indexPath.section];
    ClassMomentListRequestItem_Data_Moment_Comment *comment = moment.comments[indexPath.row];
    [cell reloadName:comment.publisher.realName withComment:comment.content withLast:indexPath.row + 1 == moment.comments.count];
    return cell;
}
#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ClassMomentHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ClassMomentHeaderView"];
    ClassMomentListRequestItem_Data_Moment *moment = self.dataArray[section];
    headerView.moment = moment;
    WEAK_SELF
    headerView.classMomentReportBlock = ^{
        STRONG_SELF
        ReportViewController *vc = [[ReportViewController alloc] init];
        vc.userId = moment.publisher.userID;
        vc.objectId = moment.momentID;
        [self.navigationController pushViewController:vc animated:YES];
    };
    headerView.classMomentLikeCommentBlock = ^(UIButton *sender) {
        STRONG_SELF
        CGRect rect = [sender convertRect:sender.bounds toView:self.view];
        [self showFloatView:rect withSection:section];
    };
    headerView.classMomentOpenCloseBlock = ^(BOOL isOpen) {
        STRONG_SELF
        moment.isOpen = [NSString stringWithFormat:@"%@",@(!isOpen)];
        [self.tableView reloadData];
    };
    return headerView;
}
- (void)showFloatView:(CGRect)rect withSection:(NSInteger)section{
    if (self.floatingView.superview != nil) {
        [self.floatingView hiddenViewAnimate:YES];
        return;
    }
    ClassMomentListRequestItem_Data_Moment *moment = self.dataArray[section];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:NSNotFound inSection:section];
    if (moment.comments.count > 0) {
        indexPath = [NSIndexPath indexPathForRow:moment.comments.count - 1 inSection:section];
    }
    WEAK_SELF
    self.floatingView.classMomentFloatingBlock = ^(ClassMomentClickStatus status) {
        STRONG_SELF
        if (status == ClassMomentClickStatus_Comment) {
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            self.commtentInteger = section;
            if (moment.draftModel != nil) {
                self.inputView.textString = moment.draftModel;
            }
            [self.inputView.textView becomeFirstResponder];
        }else if (status == ClassMomentClickStatus_Like){
            [self requestForClickLike:section];
        }else {
            [self requestForDelete:section];
        }
    };
    [self.view addSubview:self.floatingView];
    __block BOOL isLike = NO;
    [moment.likes enumerateObjectsUsingBlock:^(ClassMomentListRequestItem_Data_Moment_Like *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.publisher.userID.integerValue == [UserManager sharedInstance].userModel.userID.integerValue) {
            isLike = YES;
            *stop = YES;
        }
    }];
    if (isLike) {
        [self.floatingView reloadFloatingView:rect withStyle:ClassMomentFloatingStyle_Comment | ClassMomentFloatingStyle_Delete];
    }else {
        [self.floatingView reloadFloatingView:rect withStyle:ClassMomentFloatingStyle_Comment | ClassMomentFloatingStyle_Like | ClassMomentFloatingStyle_Delete];
    }

}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ClassMomentFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ClassMomentFooterView"];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    ClassMomentListRequestItem_Data_Moment *moment = self.dataArray[section];
    if (moment.likes.count > 0 || moment.comments.count > 0) {
        return 16.0f;
    }
    return 1.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"ClassMomentCell" configuration:^(ClassMomentCell *cell) {
        ClassMomentListRequestItem_Data_Moment *moment = self.dataArray[indexPath.section];
        ClassMomentListRequestItem_Data_Moment_Comment *comment = moment.comments[indexPath.row];
        [cell reloadName:comment.publisher.realName withComment:comment.content withLast:indexPath.row];
    }];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self hiddenInputTextView];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self tableHeightForHeaderInSection:section];
}
- (CGFloat)tableHeightForHeaderInSection:(NSInteger)section {
    //
    ClassMomentListRequestItem_Data_Moment *moment = self.dataArray[section];
    CGFloat photoHeight = (SCREEN_WIDTH - 15.0f - 40.0f - 10.0f - 15.0f) * 348.0f/590.0f;
    CGFloat contentHeight = [self sizeForTitle:moment.content?:@""];
    CGFloat height = 15.0f + 5.0f + 14.0f + 6.0f;
    if (contentHeight >= 85.0f) {
        if (!moment.isOpen.boolValue) {
            height += 85.0f;
        }else {
            height += contentHeight;
        }
        height += 14.0 + 10.0f;
    }else {
        height += contentHeight + 1.0f;
    }
    if (moment.albums.count > 0) {
        height += photoHeight + 15.0f;
    }
#warning 只显示一张图片
//    if (moment.albums.count > 0 && moment.albums.count < 2) {
//        height += photoHeight + 15.0f;
//    }else if (moment.albums.count >= 2 && moment.albums.count < 4 ){
//        height = height + (SCREEN_WIDTH - 15.0f - 60.0f - 10.0f - 15.0f - 10.0f)/3.0f;
//    }else if(moment.albums.count >= 4 && moment.albums.count <= 6){
//        height = height + (SCREEN_WIDTH - 15.0f - 60.0f - 10.0f - 15.0f - 10.0f)/3.0f * 2.0f + 5.0f;
//    }else {
//        height = height + SCREEN_WIDTH - 15.0f - 60.0f - 10.0f - 15.0f - 10.0f + 10.0f;
//    }

    height = height + 10.0f + 30.0f;
    if (moment.likes.count == 0 && moment.comments.count == 0) {
        height = height + 5.0f;
        
    }else if (moment.likes.count != 0 && moment.comments.count != 0) {
        NSMutableArray *mutableArrray = [[NSMutableArray alloc] init];
        [moment.likes enumerateObjectsUsingBlock:^(ClassMomentListRequestItem_Data_Moment_Like *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [mutableArrray addObject:obj.publisher.realName?:@""];
        }];
        height = height + 5.0f + 7.0f + [self sizeForLikes:[mutableArrray componentsJoinedByString:@","]] + 10.0f + 20.0f - 5.0f;
        
    }else if (moment.likes.count != 0) {
        NSMutableArray *mutableArrray = [[NSMutableArray alloc] init];
        [moment.likes enumerateObjectsUsingBlock:^(ClassMomentListRequestItem_Data_Moment_Like *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [mutableArrray addObject:obj.publisher.realName?:@""];
        }];
        height = height + 7.0f + 7.0f + 10.0f + [self sizeForLikes:[mutableArrray componentsJoinedByString:@","]] + 10.0f -5.0f;
    }else {
        NSMutableArray *mutableArrray = [[NSMutableArray alloc] init];
        [moment.likes enumerateObjectsUsingBlock:^(ClassMomentListRequestItem_Data_Moment_Like *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [mutableArrray addObject:obj.publisher.realName?:@""];
        }];
        height = height + 7.0f + 10.0f + 10.0f;
    }
    return ceil(height);
}
- (CGFloat)sizeForLikes:(NSString *)title {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 1.2f;
    CGRect rect = [title boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 15.0f - 40.0f - 10.0f - 15.0f - 8.0f - 12.0f - 6.0f - 25.0f, 999)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                NSParagraphStyleAttributeName :paragraphStyle} context:NULL];
    return rect.size.height;
}
- (CGFloat)sizeForTitle:(NSString *)title {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 1.2f;
    CGRect rect = [title boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 15.0f - 40.0f - 10.0f - 15.0f, 1999)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                NSParagraphStyleAttributeName :paragraphStyle} context:NULL];
    return rect.size.height;
}


#pragma mark - request
- (void)requestForDelete:(NSInteger)section {
    [TalkingData trackEvent:@"删除班级圈"];
    ClassMomentListRequestItem_Data_Moment *moment = self.dataArray[section];
    ClassMomentDeleteRequest *request = [[ClassMomentDeleteRequest alloc] init];
    request.momentId = moment.momentID;
    [self.view nyx_startLoading];
    WEAK_SELF
    [request startRequestWithRetClass:[HttpBaseRequestItem class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
        STRONG_SELF
        [self.view nyx_stopLoading];
        ClassMomentClickLikeRequestItem *item = retItem;
        if (error) {
            [self.view nyx_showToast:error.localizedDescription];
            return;
        }
        if (item.code.integerValue == 0) {
            [self.dataArray removeObjectAtIndex:section];
            self.emptyView.hidden = self.dataArray.count == 0 ? NO : YES;
        }else {
            [self.view nyx_showToast:item.message];
        }
        [self.tableView reloadData];
    }];
    self.deleteRequest = request;
}
- (void)requestForClickLike:(NSInteger)section {
    ClassMomentListRequestItem_Data_Moment *moment = self.dataArray[section];
    ClassMomentClickLikeRequest *request = [[ClassMomentClickLikeRequest alloc] init];
    request.clazsId = [UserManager sharedInstance].userModel.currentClass.clazsId;
    request.momentId = moment.momentID;
//    [self.view nyx_startLoading];
    WEAK_SELF
    [request startRequestWithRetClass:[ClassMomentClickLikeRequestItem class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
        STRONG_SELF
        [self.view nyx_stopLoading];
        ClassMomentClickLikeRequestItem *item = retItem;
        if (error) {
            [self.view nyx_showToast:error.localizedDescription];
            return;
        }
        if (item.data != nil) {
            if (moment.likes.count == 0) {
                NSMutableArray<ClassMomentListRequestItem_Data_Moment_Like> *mutableArray = [[NSMutableArray<ClassMomentListRequestItem_Data_Moment_Like> alloc] init];
                [mutableArray addObject:item.data];
                moment.likes = mutableArray;
            }else {
                [moment.likes addObject:item.data];
            }
            [self.tableView beginUpdates];
            [self.tableView reloadData];
            [self.tableView endUpdates];
        }else {
            [self.view nyx_showToast:item.message];
        }
    }];
    self.clickLikeRequest = request;
}
- (void)requstForPublishComment:(NSString *)content {
    ClassMomentListRequestItem_Data_Moment *moment = self.dataArray[self.commtentInteger];
    ClassMomentCommentRequest *request = [[ClassMomentCommentRequest alloc] init];
    request.clazsId = [UserManager sharedInstance].userModel.currentClass.clazsId;
    request.momentId = moment.momentID;
    request.content = content;
//    [self.view nyx_startLoading];
    WEAK_SELF
    [request startRequestWithRetClass:[ClassMomentCommentRequestItem class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
        STRONG_SELF
        [self.view nyx_stopLoading];
        ClassMomentCommentRequestItem *item = retItem;
        if (error) {
            [self.view nyx_showToast:error.localizedDescription];
            return;
        }
        if (item.data != nil) {
            item.data.content = content;
            if (moment.comments.count == 0) {
                NSMutableArray<ClassMomentListRequestItem_Data_Moment_Comment> *mutableArray = [[NSMutableArray<ClassMomentListRequestItem_Data_Moment_Comment> alloc] init];
                [mutableArray addObject:item.data];
                moment.comments = mutableArray;
            }else {
                [moment.comments addObject:item.data];
            }
            moment.draftModel = nil;
            self.inputView.textString = nil;
            [self.tableView reloadData];
        }else {
            [self.view nyx_showToast:item.message];
        }
    }];
    self.commentRequest = request;
}
@end
