//
//  MainPageTopView.m
//  FaceShowApp
//
//  Created by niuzhaowang on 2017/9/15.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import "MainPageTopView.h"

@interface MainPageTopView()
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *projectLabel;
@property (nonatomic, strong) UILabel *classLabel;
@property (nonatomic, strong) UILabel *studentLabel;
@property (nonatomic, strong) UILabel *teacherLabel;
@end

@implementation MainPageTopView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.bgImageView = [[UIImageView alloc]init];
    self.bgImageView.image = [UIImage imageNamed:@"背景图片"];
    self.bgImageView.userInteractionEnabled = YES;
    self.bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bgImageView.clipsToBounds = YES;
    [self addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    WEAK_SELF
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [[gestureRecognizer rac_gestureSignal] subscribeNext:^(UITapGestureRecognizer *x) {
        STRONG_SELF
        if (x.state == UIGestureRecognizerStateEnded) {
            BLOCK_EXEC(self.mainPagePushDetailBlock);
        }
    }];
    [self.bgImageView addGestureRecognizer:gestureRecognizer];
    
    UIView *topView = [[UIView alloc]init];
    [self addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(60, 24));
    }];
    CAShapeLayer *layer = [[CAShapeLayer alloc]init];
    layer.frame = CGRectMake(0, 0, 60, 24);
    layer.fillColor = [[UIColor blackColor]colorWithAlphaComponent:0.3].CGColor;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:layer.frame byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(6, 6)];
    layer.path = path.CGPath;
    [topView.layer addSublayer:layer];
    UILabel *topLabel = [[UILabel alloc]init];
    topLabel.font = [UIFont systemFontOfSize:10];
    topLabel.textColor = [UIColor whiteColor];
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.text = @"当前项目";
    [topView addSubview:topLabel];
    [topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.classLabel = [[UILabel alloc]init];
    self.classLabel.textColor = [UIColor whiteColor];
    self.classLabel.font = [UIFont boldSystemFontOfSize:13];
    self.classLabel.textAlignment = NSTextAlignmentCenter;
    self.classLabel.layer.cornerRadius = 6;
    self.classLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.classLabel.layer.borderWidth = 1;
    [self addSubview:self.classLabel];
    [self.classLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topView.mas_bottom).mas_offset(67);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(26);
        make.left.mas_greaterThanOrEqualTo(15);
        make.right.mas_lessThanOrEqualTo(-15);
    }];
    self.projectLabel = [[UILabel alloc]init];
    self.projectLabel.textColor = [UIColor whiteColor];
    self.projectLabel.font = [UIFont boldSystemFontOfSize:18];
    self.projectLabel.textAlignment = NSTextAlignmentCenter;
    self.projectLabel.numberOfLines = 2;
    [self addSubview:self.projectLabel];
    [self.projectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.top.mas_equalTo(topView.mas_bottom);
        make.bottom.mas_equalTo(self.classLabel.mas_top);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithHexString:@"96bde4"];
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(1.0f, 13.0f));
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.classLabel.mas_bottom).offset(18.0f);
    }];
    self.studentLabel = [[UILabel alloc] init];
    self.studentLabel.textColor = [UIColor whiteColor];
    self.studentLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    self.studentLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.studentLabel];
    [self.studentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(lineView.mas_left).offset(-15.0f);
        make.centerY.equalTo(lineView.mas_centerY);
    }];
    self.teacherLabel = [[UILabel alloc] init];
    self.teacherLabel.textColor = [UIColor whiteColor];
    self.teacherLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    [self addSubview:self.teacherLabel];
    [self.teacherLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lineView.mas_right).offset(15.0f);
        make.centerY.equalTo(lineView.mas_centerY);
    }];
}
#pragma mark - set
- (void)setClazsInfo:(ClazsGetClazsRequestItem_Data_ClazsInfo *)clazsInfo {
    _clazsInfo = clazsInfo;
    self.classLabel.text = _clazsInfo.clazsName;
    [self.classLabel sizeToFit];
    [self.classLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.classLabel.width+20);
    }];
    [self setNeedsLayout];
    if (self.classLabel.text.length == 0) {
        self.classLabel.hidden = YES;
    }

}
- (void)setProjectInfo:(ClazsGetClazsRequestItem_Data_ProjectInfo *)projectInfo {
    _projectInfo = projectInfo;
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineHeightMultiple = 1.2;
    paraStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *dic = @{NSParagraphStyleAttributeName:paraStyle};
    NSString *project = _projectInfo.projectName;
    NSAttributedString *projectAttributeStr = [[NSAttributedString alloc] initWithString:project attributes:dic];
    self.projectLabel.attributedText = projectAttributeStr;
}
- (void)setClazsStatistic:(ClazsGetClazsRequestItem_Data_ClazsStatisticView *)clazsStatistic {
    _clazsStatistic = clazsStatistic;
    self.studentLabel.text = [NSString stringWithFormat:@"班级学员: %@人",_clazsStatistic.studensNum?:@""];
    self.teacherLabel.text = [NSString stringWithFormat:@"班主任: %@人",_clazsStatistic.masterNum?:@""];
}

@end
