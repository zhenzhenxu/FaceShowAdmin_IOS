//
//  PagedListViewControllerBase.m
//  YanXiuApp
//
//  Created by Lei Cai on 5/21/15.
//  Copyright (c) 2015 yanxiu. All rights reserved.
//

#import "PagedListViewControllerBase.h"

@interface PagedListViewControllerBase () 
@end

@implementation PagedListViewControllerBase

- (id)init {
    self = [super init];
    if (self) {
        _bNeedHeader = YES;
        _bNeedFooter = YES;
        _bIsGroupedTableViewStyle = NO;
    }
    return self;
}

- (void)dealloc
{
    DDLogWarn(@"PagedListViewController Dealloc");
    [_header free];
    [_footer free];
    [self.dataFetcher stop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    if (self.bIsGroupedTableViewStyle) {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    } else {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    }
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    if (!self.emptyView) {
        self.emptyView = [[EmptyView alloc]init];
    }
    self.emptyView.hidden = YES;
    [self.view addSubview:self.emptyView];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(@0);
    }];
    
    if (!self.errorView) {
        self.errorView = [[ErrorView alloc]init];
    }
    @weakify(self);
    [self.errorView setRetryBlock:^{
        @strongify(self); if (!self) return;
        [self.view nyx_startLoading];
        [self firstPageFetch];
    }];
    [self.view addSubview:self.errorView];
    [self.errorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(@0);
    }];
    [self hideErrorView];
    
    if (self.bNeedFooter) {
        _footer = [MJRefreshFooterView footer];
        _footer.scrollView = self.tableView;
        _footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
            @strongify(self); if (!self) return;
            [self morePageFetch];
        };
        _footer.alpha = 0;
    }
    
    if (self.bNeedHeader) {
        _header = [MJRefreshHeaderView header];
        _header.scrollView = self.tableView;
        _header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
            @strongify(self); if (!self) return;
            [self firstPageFetch];
        };
    }
    
    self.dataArray = [NSMutableArray array];
    [self.dataArray addObjectsFromArray:[self.dataFetcher cachedItemArray]];
    _total = (int)[self.dataArray count];
    self.requestDelegate = self.dataFetcher;
    [self.view nyx_startLoading];
    [self firstPageFetch];
}

- (void)firstPageFetch {
    if (!self.dataFetcher) {
        return;
    }
    [self.dataFetcher stop];

    SAFE_CALL(self.requestDelegate, requestWillRefresh);
    @weakify(self);
    [self.dataFetcher startWithBlock:^(int total, NSArray *retItemArray, NSError *error) {
        @strongify(self); if (!self) return;
        SAFE_CALL_OneParam(self.requestDelegate, requestEndRefreshWithError, error);
        [self.view nyx_stopLoading];
        [self stopAnimation];
        if (error) {
            if (isEmpty(self.dataArray)) {  // no cache 强提示, 加载失败界面
                self->_total = 0;
                [self showErroView];
            } else {
                [self.view nyx_showToast:error.localizedDescription];
            }
            [self checkHasMore];
            return;
        }
        
        // 隐藏失败界面
        [self hideErrorView];
        
        [self->_header setLastUpdateTime:[NSDate date]];
        self.total = total;
        [self.dataArray removeAllObjects];
        
        if (isEmpty(retItemArray)) {
            self.emptyView.hidden = NO;
        } else {
            self.emptyView.hidden = YES;
            [self.dataArray addObjectsFromArray:retItemArray];
            [self checkHasMore];
            [self.dataFetcher saveToCache];
        }
        [self.tableView reloadData];
    }];
}

- (void)stopAnimation
{
    [self->_header endRefreshing];
}

- (void)setPulldownViewHidden:(BOOL)hidden
{
    _header.alpha = hidden ? 0:1;
}

- (void)setPullupViewHidden:(BOOL)hidden
{
//    if (!hidden) {
//        @weakify(self);
//        [_footer free];
//        _footer = [MJRefreshFooterView footer];
//        _footer.scrollView = self.tableView;
//        _footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
//            @strongify(self); if (!self) return;
//            [self morePageFetch];
//        };
//        _footer.alpha = 0;
//    }
    _footer.alpha = hidden ? 0:1;
}
- (void)morePageFetch {
    [self.dataFetcher stop];
    //self.dataFetcher.pageindex++;
    SAFE_CALL(self.requestDelegate, requestWillFetchMore);
    @weakify(self);
    [self.dataFetcher startWithBlock:^(int total, NSArray *retItemArray, NSError *error) {
        @strongify(self); if (!self) return;
        SAFE_CALL_OneParam(self.requestDelegate, requestEndFetchMoreWithError, error);
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self); if (!self) return;
            [self->_footer endRefreshing];
            if (error) {
                self.dataFetcher.pageindex--;
                [self.view nyx_showToast:error.localizedDescription];
                return;
            }
            
            [self.dataArray addObjectsFromArray:retItemArray];
            self.total = total;
            [self.tableView reloadData];
            [self checkHasMore];
        });
    }];
}

- (void)showErroView {
//    [self.view addSubview:self.errorView];
//    [self.errorView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(@0);
//    }];
    self.errorView.hidden = NO;
    [self.view bringSubviewToFront:self.errorView];
}

- (void)hideErrorView {
//    [self.errorView removeFromSuperview];
    self.errorView.hidden = YES;
}

- (void)checkHasMore {
    // there is a bug is MJRefresh, so we use alpha instead of hidden
    [self setPullupViewHidden:[self.dataArray count] >= _total];
}
#pragma mark - tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    return cell;
}


//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 100;
//}

@end
