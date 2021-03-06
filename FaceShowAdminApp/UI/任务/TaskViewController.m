//
//  TaskViewController.m
//  FaceShowAdminApp
//
//  Created by niuzhaowang on 2017/10/25.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import "TaskViewController.h"
#import "TaskListCell.h"
#import "EmptyView.h"
#import "ErrorView.h"
#import "GetTaskRequest.h"
#import "FSDataMappingTable.h"
#import "MJRefresh.h"
#import "QuestionnaireViewController.h"
#import "SignInDetailRequest.h"
#import "SignInDetailViewController.h"
#import "YXDrawerController.h"

@interface TaskViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EmptyView *emptyView;
@property (nonatomic, strong) ErrorView *errorView;
@property (nonatomic, strong) GetTaskRequest *request;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) MJRefreshHeaderView *header;
@property (nonatomic, strong) SignInDetailRequest *getSigninRequest;
@property (nonatomic, strong) SignInListRequestItem_signIns *signIn;
@end

@implementation TaskViewController

- (void)dealloc {
    [self.header free];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    WEAK_SELF
    [self nyx_setupLeftWithImageName:@"抽屉列表按钮正常态" highlightImageName:@"抽屉列表按钮点击态" action:^{
        STRONG_SELF
        [YXDrawerController showDrawer];
    }];
    [self setupUI];
    [self setupObserver];
    [self requestTaskInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestTaskInfo {
    [self.view nyx_startLoading];
    WEAK_SELF
    [self.request stopRequest];
    self.request = [[GetTaskRequest alloc] init];
    self.request.clazsId = [UserManager sharedInstance].userModel.currentClass.clazsId;
//    self.request.clazsId = @"9";
    [self.request startRequestWithRetClass:[GetTaskRequestItem class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
        STRONG_SELF
        [self.header endRefreshing];
        [self.view nyx_stopLoading];
        self.errorView.hidden = YES;
        self.emptyView.hidden = YES;
        if (error) {
            self.errorView.hidden = NO;
            return;
        }
        GetTaskRequestItem *item = (GetTaskRequestItem *)retItem;
        if (isEmpty(item.data.tasks)) {
            self.emptyView.hidden = NO;
            return;
        }
        self.dataArray = [NSArray arrayWithArray:item.data.tasks];
        [self.tableView reloadData];
    }];
}

#pragma mark - setupUI
- (void)setupUI {
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 5)];
    self.tableView.tableHeaderView = headerView;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"ebeff2"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[TaskListCell class] forCellReuseIdentifier:@"TaskListCell"];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.emptyView = [[EmptyView alloc]init];
    self.emptyView.title = @"尚未发布任务";
    [self.view addSubview:self.emptyView];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.emptyView.hidden = YES;
    self.errorView = [[ErrorView alloc]init];
    WEAK_SELF
    [self.errorView setRetryBlock:^{
        STRONG_SELF
        [self requestTaskInfo];
    }];
    [self.view addSubview:self.errorView];
    [self.errorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.errorView.hidden = YES;
    
    self.header = [MJRefreshHeaderView header];
    self.header.scrollView = self.tableView;
    self.header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        STRONG_SELF
        [self requestTaskInfo];
    };
}

#pragma mark - Observer
- (void)setupObserver {
//    WEAK_SELF
//    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"kReloadSignInRecordNotification" object:nil] subscribeNext:^(NSNotification *x) {
//        STRONG_SELF
//        NSDictionary *dic = (NSDictionary *)x.object;
//        NSIndexPath *currentIndex = [dic objectForKey:@"kSignInRecordCurrentIndexPath"];
//        //        NSString *signInTime = [dic valueForKey:@"kCurrentIndexPathSucceedSigninTime"];
//        //        GetSignInRecordListRequestItem_SignIn *signIn = self.signIn;
//        //        GetSignInRecordListRequestItem_UserSignIn *userSignIn = [GetSignInRecordListRequestItem_UserSignIn new];
//        //        userSignIn.signinTime = signInTime;
//        //        signIn.userSignIn = userSignIn;
//        GetTaskRequestItem_Task *task = self.dataArray[currentIndex.row];
//        task.stepFinished = @"1";
//        [self.tableView reloadRowsAtIndexPaths:@[currentIndex] withRowAnimation:UITableViewRowAnimationNone];
//    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskListCell"];
    cell.data = self.dataArray[indexPath.row];
    cell.lineHidden = indexPath.row==self.dataArray.count-1;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GetTaskRequestItem_Task *task = self.dataArray[indexPath.row];
    InteractType type = [FSDataMappingTable InteractTypeWithKey:task.interactType];
    if (type == InteractType_Vote || type == InteractType_Questionare) {
        QuestionnaireViewController *vc = [[QuestionnaireViewController alloc]initWithStepId:task.stepId interactType:type];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (type == InteractType_SignIn) {
        [self.getSigninRequest stopRequest];
        self.getSigninRequest = [[SignInDetailRequest alloc]init];
        self.getSigninRequest.stepId = task.stepId;
        WEAK_SELF
        [self.view nyx_startLoading];
        [self.getSigninRequest startRequestWithRetClass:[SignInDetailRequestItem class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
            STRONG_SELF
            [self.view nyx_stopLoading];
            if (error) {
                [self.view nyx_showToast:error.localizedDescription];
                return;
            }
            SignInDetailRequestItem *item = retItem;
            SignInDetailViewController *signInDetailVC = [[SignInDetailViewController alloc] init];
            item.data.signIn.stepId = task.stepId;
            signInDetailVC.data = item.data.signIn;
            [self.navigationController pushViewController:signInDetailVC animated:YES];
        }];
    }
}

@end
