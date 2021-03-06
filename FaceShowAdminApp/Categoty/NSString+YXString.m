//
//  NSString+YXString.m
//  YXKit
//
//  Created by ChenJianjun on 15/5/12.
//  Copyright (c) 2015年 yanxiu.com. All rights reserved.
//

#import "NSString+YXString.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (YXString)

@dynamic dictionary;

- (BOOL)yx_isValidString
{
    if (nil == self
        || ![self isKindOfClass:[NSString class]]
        || [self yx_stringByTrimmingCharacters].length <= 0) {
        return NO;
    }
    return YES;
}

- (NSString *)yx_safeString
{
    if ([self yx_isValidString]) {
        return self;
    }
    return @"";
}

- (NSString *)yx_stringByTrimmingCharacters
{
    NSString *string = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet controlCharacterSet]];
    return string;
}

- (NSString *)nyx_stringByTrimmingExtraSpaces {    
    NSArray *array = [self componentsSeparatedByString:@" "];
    NSMutableArray *marray = [NSMutableArray new];
    for (NSString *stringOne in array) {
        //删除字符串中的所有空格
        NSString *zufuchuan = [[stringOne stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
        if (zufuchuan.length != 0) {
            [marray addObject:stringOne];
        }
    }
    
    NSString *mString = [marray componentsJoinedByString:@" "];
    //去除 字符串两端的空格 和回车
    mString = [mString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    return mString;
}

- (int)isAscendingCompareDate:(NSString *)date{
    int ci;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH-mm"];
    NSDate *dt1 = [[NSDate alloc] init];
    NSDate *dt2 = [[NSDate alloc] init];
    dt1 = [df dateFromString:self];
    dt2 = [df dateFromString:date];
    NSComparisonResult result = [dt1 compare:dt2];
    switch (result)
    {
            //date02比date01大
        case NSOrderedAscending: ci=1; break;
            //date02比date01小
        case NSOrderedDescending: ci=-1; break;
            //date02=date01
        case NSOrderedSame: ci=0;break;
    }
    return ci;
}

- (NSString *)yx_encodeString
{
    CFStringRef stringFef = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                    (__bridge CFStringRef)self,
                                                                    NULL,
                                                                    (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                    kCFStringEncodingUTF8);
    return (__bridge_transfer NSString *)stringFef;
}

- (NSString *)yx_decodeString
{
    NSMutableString *resultString = [NSMutableString stringWithString:self];
    [resultString replaceOccurrencesOfString:@"+"
                                  withString:@" "
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, [resultString length])];
    return [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end

@implementation NSString (YXTextChecking)

- (BOOL)yx_textCheckingWithPattern:(NSString *)pattern
{
    if ([pattern yx_isValidString]
        && [self yx_isValidString]) {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSTextCheckingResult *firstMacth = [regex firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
        if (firstMacth) {
            return YES;
        }
    }
    return NO;
}

/*
 * ^[1]，首字母必须是1
 * [3-8]，第二个数字为3-8之间
 * +，表示至少一个[3-8]
 * \\d，表示数字
 * {9}，表示后面包含9个数字
 * $，结束符
 */
- (BOOL)yx_isPhoneNum
{
    NSString *phoneNum = [self yx_stringByTrimmingCharacters];
    phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@" " withString:@""];
    return (phoneNum.length == 11) && [phoneNum yx_textCheckingWithPattern:@"^[1][3-8]+\\d{9}$"];
}

- (BOOL)yx_isHttpLink
{
    if (![self yx_isValidString]) {
        return NO;
    }
    NSString *link = [self yx_stringByTrimmingCharacters];
    if ([link hasPrefix:@"http"]
        || [link hasPrefix:@"https"]
        || [link hasPrefix:@"www."]) {
        return YES;
    }
    return NO;
}

- (NSString *)yx_md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

- (BOOL)nyx_isPureInt{
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (NSDictionary *)dictionary{
    if (self == nil) {
        return nil;
    }
    
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (BOOL)includeChinese {
    for (int i = 0; i < [self length]; i++) {
        int a = [self characterAtIndex:i];
        if (a > 0x4e00 && a < 0x9fff) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)includeEmoji {
    __block BOOL returnValue = NO;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
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

@end

@implementation NSString (YXTextFormatConvert)

- (NSString *)omitSecondOfFullDateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [dateFormatter dateFromString:self];
    if (isEmpty(date)) {
        return self;
    }
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    return [dateFormatter stringFromDate:date];
}

@end
