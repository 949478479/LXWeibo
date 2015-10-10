//
//  LXStatus.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/28.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXConst.h"
#import "LXStatus.h"
#import "RegexKitLite.h"
#import "LXStatusTextPart.h"
#import "LXEmotionsManager.h"

@implementation LXStatus

@synthesize source         = _source;
@synthesize created_at     = _created_at;
@synthesize attributedText = _attributedText;

+ (NSDictionary *)objectClassInArray
{
    return @{ @"pic_urls" : [LXPhoto class] };
}

#pragma mark - 微博来源处理

- (void)setSource:(NSString * _Nonnull)source
{
    // <a href=\"http://app.weibo.com/t/feed/1tqBja\" rel=\"nofollow\">360安全浏览器</a>
    NSRange range = [source rangeOfString:@"(?<=>).+(?=<)" options:NSRegularExpressionSearch];

    // 发现个别时候来源为 @"" .
    if (range.location != NSNotFound) {
        _source = [NSString stringWithFormat:@"来自 %@", [source substringWithRange:range]];
    } else {
        _source = source;
    }
}

#pragma mark - 发表时间格式化处理

static inline NSDateFormatter * LXDateFromStringFormatter()
{
    static NSDateFormatter *sDateFromStringFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sDateFromStringFormatter = [NSDateFormatter new];
        sDateFromStringFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        sDateFromStringFormatter.dateFormat = @"E MMM dd HH:mm:ss Z y"; // @"Tue Sep 30 17:06:25 +0800 2014"
    });
    return sDateFromStringFormatter;
}

static inline NSDateFormatter * LXNoThisYearFormatterFormatter()
{
    static NSDateFormatter *sNoThisYearFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sNoThisYearFormatter = [NSDateFormatter new];
        sNoThisYearFormatter.dateFormat = @"y-MM-dd HH:mm";
    });
    return sNoThisYearFormatter;
}

static inline NSDateFormatter * LXYesterdayFormatter()
{
    static NSDateFormatter *sYesterdayFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sYesterdayFormatter = [NSDateFormatter new];
        sYesterdayFormatter.dateFormat = @"昨天 HH:mm";
    });
    return sYesterdayFormatter;
}

static inline NSDateFormatter * LXOtherDayInThisYearFormatter()
{
    static NSDateFormatter *sOtherDayInThisYearFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sOtherDayInThisYearFormatter = [NSDateFormatter new];
        sOtherDayInThisYearFormatter.dateFormat = @"MM-dd HH:mm";
    });
    return sOtherDayInThisYearFormatter;
}

- (NSString *)created_at
{
    NSDate *created_at = [LXDateFromStringFormatter() dateFromString:_created_at];

    NSAssert(created_at, @"日期格式化失败.");

    NSTimeInterval timeInterval = -[created_at timeIntervalSinceNow];

    NSCAssert(timeInterval >= 0, @"发表时间晚于当前时间.");

    if (timeInterval < 60 || timeInterval < 0) // 1 分钟内.如果出现时间晚于当前时间的诡异情况按"刚刚"处理.
    {
        return @"刚刚";
    }
    else if (timeInterval < 3600) // 1 小时内.
    {
        return [NSString stringWithFormat:@"%d分钟前", (int)(timeInterval / 60)];
    }
    else // 1 小时以上.
    {
        BOOL isToday = [LXDateFromStringFormatter().calendar isDateInToday:created_at];

        if (isToday) // 今天.
        {
            return [NSString stringWithFormat:@"%d小时前", (int)(timeInterval / 3600)];
        }
        else // 非今天.
        {
            BOOL isYesterday = [LXDateFromStringFormatter().calendar isDateInYesterday:created_at];

            if (isYesterday) // 昨天. 格式类似: 昨天 23:39
            {
                return [LXYesterdayFormatter() stringFromDate:created_at];
            }
            else // 非昨天.
            {
                BOOL isThisYear = [LXDateFromStringFormatter().calendar isDate:created_at
                                                                   equalToDate:[NSDate date]
                                                             toUnitGranularity:NSCalendarUnitYear];

                if (isThisYear) // 今年. 格式类似: 10-29 23:39
                {
                    return [LXOtherDayInThisYearFormatter() stringFromDate:created_at];
                }
                else // 非今年. 格式类似: 2012-04-01 19:17
                {
                    return [LXNoThisYearFormatterFormatter() stringFromDate:created_at];
                }
            }
        }
    }
}

#pragma mark - 图文混排处理

// @ #话题# [表情]
static NSString * const kRegexPattern = @"@[\\w-_]+|#[\\w]+#|\\[\\w+\\]";
static UIFont *sStatusTextFont = nil;
static NSDictionary *sSpecialAttributes = nil;

+ (void)initialize
{
    sSpecialAttributes = @{ NSForegroundColorAttributeName : [UIColor blueColor] };
    sStatusTextFont = [UIFont systemFontOfSize:LXStatusTextFontSize];
}

- (NSMutableArray<LXStatusTextPart *> *)statusTextPartsWithText:(NSString *)text
{
    NSMutableArray<LXStatusTextPart *> *parts = [NSMutableArray new];

    // 匹配特殊字段.
    [text enumerateStringsMatchedByRegex:kRegexPattern
                              usingBlock:^(NSInteger captureCount,
                                           NSString *const __unsafe_unretained *capturedStrings,
                                           const NSRange *capturedRanges,
                                           volatile BOOL *const stop) {
                                  NSAssert((*capturedRanges).length > 0, @"尼玛长度能为0?");
                                  LXStatusTextPart *part = [LXStatusTextPart new];
                                  {
                                      part.text  = *capturedStrings;
                                      part.range = *capturedRanges;
                                      part.isEmotion = [*capturedStrings hasPrefix:@"["];
                                      part.isSpecial = YES;
                                  }
                                  [parts addObject:part];
                              }];

    // 用特殊字段分割微博文本,即匹配普通文本字段.
    [text enumerateStringsSeparatedByRegex:kRegexPattern
                                usingBlock:^(NSInteger captureCount,
                                             NSString *const __unsafe_unretained *capturedStrings,
                                             const NSRange *capturedRanges,
                                             volatile BOOL *const stop) {
                                    if ((*capturedRanges).length == 0) {
                                        return ;
                                    }
                                    LXStatusTextPart *part = [LXStatusTextPart new];
                                    {
                                        part.text  = *capturedStrings;
                                        part.range = *capturedRanges;
                                    }
                                    [parts addObject:part];
                                }];

    // 按照 location 排序字段,即还原其原本的顺序.
    [parts sortUsingComparator:^NSComparisonResult(LXStatusTextPart * _Nonnull obj1,
                                                   LXStatusTextPart * _Nonnull obj2) {
        return obj1.range.location < obj2.range.location ? NSOrderedAscending : NSOrderedDescending;
    }];

    return parts;
}

- (NSAttributedString *)attributedTextWithText:(NSString *)text
{
    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
    for (LXStatusTextPart *part in [self statusTextPartsWithText:text]) {
        NSAttributedString *subAttributedString = nil;
        if (part.isEmotion) { // 表情.
            LXEmotion *emotion = [LXEmotionsManager emotionWithCHS:part.text];
            NSTextAttachment *textAttachment = [NSTextAttachment new];
            {
                textAttachment.image = [UIImage imageNamed:emotion.png];
                textAttachment.bounds = CGRectMake(0,
                                                   sStatusTextFont.descender,
                                                   sStatusTextFont.lineHeight,
                                                   sStatusTextFont.lineHeight);
            }
            subAttributedString = [NSAttributedString attributedStringWithAttachment:textAttachment];
        } else if (part.isSpecial) { // @ #.
            subAttributedString = [[NSAttributedString alloc] initWithString:part.text
                                                                  attributes:sSpecialAttributes];
        } else { // 普通文本内容.
            subAttributedString = [[NSAttributedString alloc] initWithString:part.text];
        }
        [attributedString appendAttributedString:subAttributedString];
    }
    [attributedString addAttribute:NSFontAttributeName
                             value:sStatusTextFont
                             range:(NSRange){0,attributedString.length}];
    return attributedString;
}

- (void)setRetweeted_status:(LXStatus * _Nullable)retweeted_status
{
    _retweeted_status = retweeted_status;

    [_retweeted_status setValue:@(YES) forKey:@"retweeted"];
}

- (NSAttributedString *)attributedText
{
    if (!_attributedText) {
        if (_retweeted) { // 该微博是转发微博.
            NSString *text = [NSString stringWithFormat:@"@%@：%@", _user.name, _text];
            _attributedText = [self attributedTextWithText:text];
        } else { // 该微博是原创微博.
            _attributedText = [self attributedTextWithText:_text];
        }
    }
    return _attributedText;
}

@end