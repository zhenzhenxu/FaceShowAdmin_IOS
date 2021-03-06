//
//  publicationMomentViewController.m
//  FaceShowApp
//
//  Created by 郑小龙 on 2017/9/15.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import "PublishMomentViewController.h"
#import <SAMTextView.h>
#import "QADataManager.h"
@interface PublishMomentViewController ()<UITextViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *publicationMomentView;
@property (nonatomic, strong) SAMTextView *publicationMomentTextView;
@property (nonatomic, strong) UIImageView *publicationImageView;

@property (nonatomic, strong) ClassMomentPublishRequest *publishRequest;
@end

@implementation PublishMomentViewController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DDLogDebug(@"release========>>%@",[self class]);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"班级圈";
    [self setupUI];
    [self setupLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - setupUI
- (void)setupUI {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - 64.0f);
    self.scrollView.backgroundColor = [UIColor colorWithHexString:@"dfe2e6"];
    [self.view addSubview:self.scrollView];
    
    self.publicationMomentView = [[UIView alloc] init];
    self.publicationMomentView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.publicationMomentView];
    
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = [UIColor colorWithHexString:@"ebeff2"];
    [self.scrollView addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.publicationMomentView.mas_left);
        make.right.equalTo(self.publicationMomentView.mas_right);
        make.top.equalTo(self.publicationMomentView.mas_top);
        make.height.mas_offset(5.0f);
    }];
    self.publicationMomentTextView = [[SAMTextView alloc] init];
    self.publicationMomentTextView.delegate = self;
    self.publicationMomentTextView.font = [UIFont systemFontOfSize:14.0f];
    self.publicationMomentTextView.textColor = [UIColor colorWithHexString:@"333333"];
    self.publicationMomentTextView.placeholder = @"这一刻的想法......";
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineHeightMultiple = 1.2;
    NSDictionary *dic = @{NSParagraphStyleAttributeName:paraStyle,NSFontAttributeName:[UIFont systemFontOfSize:14]};
    self.publicationMomentTextView.typingAttributes = dic;
    [self.publicationMomentView addSubview:self.publicationMomentTextView];
    
    
    self.publicationImageView = [[UIImageView alloc] init];
    if (self.imageArray.count > 0) {
        self.publicationImageView.image = self.imageArray[0];
    }
    [self.publicationMomentView addSubview:self.publicationImageView];
    
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 40.0f, 40.0f);
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    WEAK_SELF
    [[leftButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        STRONG_SELF
        if (self.imageArray.count == 0) {
            [self dismiss];
        }else {
            [self showAlertView];
        }
    }];
    [self nyx_setupLeftWithCustomView:leftButton];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setTitle:@"发表" forState:UIControlStateNormal];
    if (self.imageArray.count == 0) {
        rightButton.enabled = NO;
    }
    rightButton.frame = CGRectMake(0, 0, 40.0f, 40.0f);
    [rightButton setTitleColor:[UIColor colorWithHexString:@"0068bd"] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateDisabled];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [[rightButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        STRONG_SELF
        [self.view nyx_startLoading];
        if (self.imageArray.count == 0) {
            [self requestForPublishMoment:nil];
        }else {
            [self requestForUploadImage];
        }
    }];
    [self nyx_setupRightWithCustomView:rightButton];
    
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UITextViewTextDidChangeNotification object:nil] subscribeNext:^(NSNotification *x) {
        STRONG_SELF
        if (self.imageArray.count != 0) {
            rightButton.enabled = YES;
            return;
        }
        UITextView *tempTextView = (UITextView *)x.object;
        rightButton.enabled = [tempTextView.text yx_stringByTrimmingCharacters].length != 0;
    }];
}


- (void)showAlertView {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"退出此次编辑" message:nil preferredStyle:UIAlertControllerStyleAlert];
    WEAK_SELF
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        STRONG_SELF
        
    }];
    [alertVC addAction:cancleAction];
    UIAlertAction *backAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STRONG_SELF
        [self dismiss];
    }];
    [alertVC addAction:backAction];
    [[self nyx_visibleViewController] presentViewController:alertVC animated:YES completion:nil];
}
- (void)setupLayout {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.publicationMomentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.scrollView.mas_top);
        make.height.mas_offset(195.0f);
    }];
    
    [self.publicationMomentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.publicationMomentView.mas_left).offset(15.0f);
        make.right.equalTo(self.publicationMomentView.mas_right).offset(-15.0f);
        make.top.equalTo(self.publicationMomentView.mas_top).offset(20.0f);
        make.height.mas_offset(self.imageArray.count > 0 ? 90.0f : 140.0f);
    }];
    
    [self.publicationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.publicationMomentView.mas_left).offset(15.0f);
        make.bottom.equalTo(self.publicationMomentView.mas_bottom).offset(-10.0f);
        make.size.mas_offset(CGSizeMake(60.0f, 60.0f));
    }];
}
- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
#pragma mark - UITextViewDelegate
-(void)textViewDidChange:(UITextView *)textView {
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.lineHeightMultiple = 1.2f;
//    textView.attributedText = [[NSAttributedString alloc] initWithString:textView.attributedText.string attributes:@{                                                                                                    NSFontAttributeName:[UIFont systemFontOfSize:15],NSParagraphStyleAttributeName:paragraphStyle}];
}
#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([[[textView textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textView textInputMode] primaryLanguage] || [self stringContainsEmoji:text]) {
        return NO;
    }
    return YES;
}
- (BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar high = [substring characterAtIndex: 0];
                                // Surrogate pair (U+1D000-1F9FF)
                                if (0xD800 <= high && high <= 0xDBFF) {
                                    const unichar low = [substring characterAtIndex: 1];
                                    const int codepoint = ((high - 0xD800) * 0x400) + (low - 0xDC00) + 0x10000;
                                    if (0x1D000 <= codepoint && codepoint <= 0x1F9FF){
                                        returnValue = YES;
                                    }
                                    // Not surrogate pair (U+2100-27BF)
                                } else {
                                    
                                    //                                    if (0x2100 <= high && high <= 0x27BF){
                                    //                                        returnValue = YES;
                                    //                                    }
                                }
                            }];
    
    return returnValue;
}
#pragma mark - request
- (void)requestForUploadImage{
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%@%d.jpg",[UserManager sharedInstance].userModel.userID, (int)interval];
    [self.view nyx_startLoading];
    WEAK_SELF
    [QADataManager uploadFile:self.imageArray[0] fileName:fileName completeBlock:^(QAFileUploadSecondStepRequestItem *item, NSError *error) {
        STRONG_SELF
         if (item.result.resid == nil){
             [self.view nyx_stopLoading];
            [self.view nyx_showToast:@"发布失败请重试"];
        }else {
            [self requestForPublishMoment:item.result.resid];
        }
    }];
}
- (void)requestForPublishMoment:(NSString *)resourceIds{
    ClassMomentPublishRequest *request = [[ClassMomentPublishRequest alloc] init];
    request.clazsId = [UserManager sharedInstance].userModel.currentClass.clazsId;
    request.content = self.publicationMomentTextView.text;
    request.resourceIds = resourceIds;
    WEAK_SELF
    [request startRequestWithRetClass:[ClassMomentPublishRequestItem class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
        STRONG_SELF
        ClassMomentPublishRequestItem *item = retItem;
        if (item.data == nil) {
            [self.view nyx_stopLoading];
            [self.view nyx_showToast:@"发布失败请重试"];
        }else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{//图片转换时间
                [self.view nyx_stopLoading];
                BLOCK_EXEC(self.publishMomentDataBlock,item.data);
                [self dismiss];
            });
            
        }
    }];
    self.publishRequest = request;
}
@end
