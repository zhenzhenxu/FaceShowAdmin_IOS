//
//  CommentInputView.m
//  FaceShowApp
//
//  Created by niuzhaowang on 2017/9/19.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import "CommentInputView.h"
#import <SAMTextView.h>

@interface CommentInputView()<UITextViewDelegate>
@property (nonatomic, assign) CGFloat textMaxHeight;
@property (nonatomic, assign) CGFloat textHeight;

@end

@implementation CommentInputView
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textMaxHeight = 83.0f;
        [self setupUI];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor colorWithHexString:@"fafafa"];
    UIView *topLine = [[UIView alloc]init];
    topLine.backgroundColor = [UIColor colorWithHexString:@"c9cacb"];
    [self addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    UIView *bottomLine = [topLine clone];
    [self addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(1);
    }];
    self.textView = [[SAMTextView alloc]init];
    self.textView.backgroundColor = [UIColor colorWithHexString:@"fcfcfc"];
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.textColor = [UIColor colorWithHexString:@"333333"];
    self.textView.returnKeyType = UIReturnKeySend;
    NSString *placeholderStr = @"评论(暂不支持表情)";
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:placeholderStr];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"666666"] range:NSMakeRange(0, placeholderStr.length)];
    [attrStr addAttribute:NSFontAttributeName value:self.textView.font range:NSMakeRange(0, placeholderStr.length)];
    self.textView.attributedPlaceholder = attrStr;
    self.textView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
    self.textView.layer.cornerRadius = 6;
    self.textView.layer.borderColor = [UIColor colorWithHexString:@"dddddd"].CGColor;
    self.textView.layer.borderWidth = 1;
    self.textView.delegate = self;
    self.textView.clipsToBounds = YES;
    [self addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(5);
        make.bottom.mas_equalTo(-5);
    }];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if ([[self.textView.text yx_stringByTrimmingCharacters] length]!=0) {
            [textView resignFirstResponder];
            BLOCK_EXEC(self.completeBlock,textView.text);
        }
        return NO;
    }
    if ([[[textView textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textView textInputMode] primaryLanguage] || [text includeEmoji]) {
        return NO;
    }
    return YES;
}

- (void)setTextString:(NSString *)textString {
    _textString = textString;
    self.textView.text = _textString;
    [self textDidChange];
}
- (void)textDidChange {
    if (!self.isChangeBool) {
        return;
    }
    NSInteger height = ceilf([self.textView sizeThatFits:CGSizeMake(self.textView.bounds.size.width, MAXFLOAT)].height);    
    if (self.textHeight != height) { // 高度不一样，就改变了高度
        // 最大高度，可以滚动
        self.textView.scrollEnabled = height > self.textMaxHeight && self.textMaxHeight > 0;
        self.textHeight = height;
        if (self.textView.scrollEnabled == NO) {
            BLOCK_EXEC(self.textHeightChangeBlock,height);
            [self.superview layoutIfNeeded];
        }
    }
}
@end
